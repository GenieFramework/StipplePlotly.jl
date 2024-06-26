/* 
    * This function is used to replace the base64 encoded plotly data with a JS string
    * that contains references to the model removing the $_{...} syntax
    * It is expected to be loaded and run by the production app before the main Vue instance is created
*/
(function processPlotlyData() {
  // Search the DOM for "plotly" elements
  let plotlyInstances = document.querySelectorAll("plotly");
  // For each plotly element...
  plotlyInstances.forEach((plotlyInstance) => {
      // List of attributes that could be base-64 encoded
      let attributeNames = ['data', 'layout', 'config'];
      // Iterate over all attributes
      attributeNames.forEach((attributeName) => {
          // Check if there's a bound attribute (i.e. :data, :layout, :config
          // Only attempt to parse encoded one (data, layout, config) if bound not found
          let literalAttribute = plotlyInstance.getAttribute(attributeName);                      // Expected to be a valid js object (binding)
          let boundAttribute = plotlyInstance.getAttribute(":"+attributeName);                    // Expected to be a valid js object (binding)
          // Both versions of attribute can't coexist
          if( literalAttribute != null && boundAttribute != null ){
              throw new Error("Both bound and literal attribute found for " + attributeName + ". Only one is allowed.");
          }
          // We don't need to do anything if there's a bound attribute (starting with ":", as it is assumed to be a valid JS object)
          if( boundAttribute != null ){
              return;
          }
          // Literal version is only expected to exist as base64-encoded json. 
          // (and just for testing purposes, it could be a non-encoded valid JS object)
          if( literalAttribute != null ){
              // Attempt to decode it and convert it to valid JS string from JSON
              try{
                  let decodeString = atob(literalAttribute);                                      // decode from base-64
                  let decodedJsString = jsonToJsString(decodeString);                             // convert to a JS string, suitable for vue
                  plotlyInstance.setAttribute(":"+attributeName, decodedJsString);                // Replace the original base64 data with the JS string
                  plotlyInstance.removeAttribute(attributeName);                                  // Remove the original base64 attribute
              }catch(e){
                  // If there's an error, check if it starts with "{" and ends with "}", or "[" and "]"
                  // If so, it's a valid JS object as a string, so we can use it as is, but adding the ":" prefix so that it gets evaluated                    
                  if( (literalAttribute.startsWith("{") && literalAttribute.endsWith("}")) ||
                  (literalAttribute.startsWith("[") && literalAttribute.endsWith("]")) ){
                      plotlyInstance.setAttribute(":"+attributeName, literalAttribute);           // Replace the original base64 data with the JS string
                      plotlyInstance.removeAttribute(attributeName);                              // Remove the original base64 attribute
                  }else{
                      throw new Error("Invalid literal attribute for " + attributeName + ". Expected a base64-encoded JSON string, or a valid JS object.");
                  }
              }
          }
      });
  });
  function jsonToJsString(jsonString) {
      // Parse the input string to a JSON object
      const jsonObj = JSON.parse(jsonString);
      // Helper function to recursively traverse and convert the object to a JS string
      // When it finds a string that starts with $_{ and ends with }, it replaces it with a reference to the contained property
      // i.e.: {a: '$_{b.c}'} => {a: b.c}
      function traverse(obj) {
          if (Array.isArray(obj)) {
              return '[' + obj.map(item => traverse(item)).join(', ') + ']';
          } else if (typeof obj === 'object') {
              return '{' + Object.keys(obj).map(key => {
                  let value = obj[key];
                  if (typeof value === 'string' && value.startsWith('$_{') && value.endsWith('}')) {
                      value = value.slice(3, -1);
                  } else {
                      value = JSON.stringify(value);
                  }
                  return `${key}:${value}`;
              }).join(', ') + '}';
          } else {
              return JSON.stringify(obj);
          }
      }
      // Convert the JSON object to a JS string
      const jsString = traverse(jsonObj);
      // Return the JS string
      return jsString;
  }
})();
const eventsName = ["AfterExport", "AfterPlot", "Animated", "AnimatingFrame", "AnimationInterrupted", "AutoSize", "BeforeExport", "ButtonClicked", "Click", "ClickAnnotation", "Deselect", "DoubleClick", "Framework", "Hover", "LegendClick", "LegendDoubleClick", "Relayout", "Restyle", "Redraw", "Selected", "Selecting", "SliderChange", "SliderEnd", "SliderStart", "Transitioning", "TransitionInterrupted", "Unhover"]
, events = eventsName.map((e=>e.toLocaleLowerCase())).map((e=>({
  completeName: "plotly_" + e,
  handler: t=>(...i)=>{
      t.$emit.apply(t, [e, ...i])
  }
})))
, plotlyFunctions = ["restyle", "relayout", "update", "addTraces", "deleteTraces", "moveTraces", "extendTraces", "prependTraces", "purge"];
function cached(e) {
  const t = Object.create(null);
  return function(i) {
      return t[i] || (t[i] = e(i))
  }
}
const regex = /-(\w)/g
, methods = plotlyFunctions.reduce(((e,t)=>(e[t] = function(...e) {
  return Plotly[t].apply(Plotly, [this.$el, ...e])
}
,
e)), {})
, camelize = cached((e=>e.replace(regex, ((e,t)=>t ? t.toUpperCase() : ""))))
, directives = {};
"undefined" != typeof window && (directives.resize = Vueresize),
Vue.component("plotly", {
  template: '<div :id="id" v-resize:debounce.100="onResize" :class="$attrs.class" :style="$attrs.style"></div>',
  inheritAttrs: !1,
  directives: directives,
  props: {
      data: {
          type: Array
      },
      layout: {
          type: Object
      },
      config: {
          type: Object
      },
      id: {
          type: String,
          required: !1,
          default: null
      }
  },
  data() {
      return {
          scheduled: null,
          innerLayout: {
              ...this.layout
          }
      }
  },
  mounted() {
      Plotly.newPlot(this.$el, this.data, this.innerLayout, this.config),
      events.forEach((e=>{
          this.$el.on(e.completeName, e.handler(this))
      }
      ))
  },
  watch: {
      data: {
          handler() {
              this.schedule({
                  replot: !0
              })
          },
          deep: !0
      },
      options: {
          handler(e, t) {
              JSON.stringify(e) !== JSON.stringify(t) && this.schedule({
                  replot: !0
              })
          },
          deep: !0
      },
      layout(e) {
          this.innerLayout = {
              ...e
          },
          this.schedule({
              replot: !1
          })
      }
  },
  computed: {
      options() {
          return {
              responsive: !1,
              ...Object.keys(this.$attrs).reduce(((e,t)=>(e[camelize(t)] = this.$attrs[t],
              e)), {})
          }
      }
  },
  beforeDestroy() {
      events.forEach((e=>this.$el.removeAllListeners(e.completeName))),
      Plotly.purge(this.$el)
  },
  methods: {
      ...methods,
      onResize() {
          Plotly.Plots.resize(this.$el)
      },
      schedule(e) {
          const {scheduled: t} = this;
          t ? t.replot = t.replot || e.replot : (this.scheduled = e,
          this.$nextTick((()=>{
              const {scheduled: {replot: e}} = this;
              this.scheduled = null,
              e ? this.react() : this.relayout(this.innerLayout)
          }
          )))
      },
      toImage(e) {
          const t = Object.assign(this.getPrintOptions(), e);
          return Plotly.toImage(this.$el, t)
      },
      downloadImage(e) {
          const t = `plot--${(new Date).toISOString()}`
            , i = Object.assign(this.getPrintOptions(), {
              filename: t
          }, e);
          return Plotly.downloadImage(this.$el, i)
      },
      getPrintOptions() {
          const {$el: e} = this;
          return {
              format: "png",
              width: e.clientWidth,
              height: e.clientHeight
          }
      },
      react() {
          Plotly.react(this.$el, this.data, this.innerLayout, this.config)
      }
  }
});