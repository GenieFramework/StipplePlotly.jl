const eventsName = [
  "AfterExport",
  "AfterPlot",
  "Animated",
  "AnimatingFrame",
  "AnimationInterrupted",
  "AutoSize",
  "BeforeExport",
  "ButtonClicked",
  "Click",
  "ClickAnnotation",
  "Deselect",
  "DoubleClick",
  "Framework",
  "Hover",
  "LegendClick",
  "LegendDoubleClick",
  "Relayout",
  "Restyle",
  "Redraw",
  "Selected",
  "Selecting",
  "SliderChange",
  "SliderEnd",
  "SliderStart",
  "Transitioning",
  "TransitionInterrupted",
  "Unhover"
];

const events = eventsName
    .map(evt => evt.toLocaleLowerCase())
    .map(eventName => ({
      completeName: "plotly_" + eventName,
      handler: context => (...args) => {
        context.$emit.apply(context, [eventName, ...args]);
      }
    }));

const plotlyFunctions = ["restyle", "relayout", "update", "addTraces",
                          "deleteTraces", "moveTraces", "extendTraces",
                          "prependTraces", "purge"];

function cached(fn) {
  const cache = Object.create(null);
  return function cachedFn(str) {
    const hit = cache[str];
    return hit || (cache[str] = fn(str));
  };
}

const regex = /-(\w)/g;

const methods = plotlyFunctions.reduce((all, functionName) => {
  all[functionName] = function(...args) {
    return Plotly[functionName].apply(Plotly, [this.$el, ...args]);
  };
  return all;
}, {});

const camelize = cached(str => str.replace(regex, (_, c) => (c ? c.toUpperCase() : "")));

const directives = {};
if (typeof window !== "undefined") {
  directives.resize = Vueresize;
}

Vue.component('plotly', {
  template: `<div :id="id" v-resize:debounce.100="onResize" ></div>`,
  inheritAttrs: false,
  directives,
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
      required: false,
      default: null
    }
  },
  data() {
    return {
      scheduled: null,
      innerLayout: { ...this.layout },
      options: { ...this.config }
    };
  },
  mounted() {
    Plotly.newPlot(this.$el, this.data, this.innerLayout, this.options);
    events.forEach(evt => {
      this.$el.on(evt.completeName, evt.handler(this));
    });
  },
  watch: {
    data: {
      handler() {
        console.log('watching');
        this.schedule({ replot: true });
      },
      deep: true
    },
    layout(layout) {
      this.innerLayout = { ...layout };
      this.schedule({ replot: false });
    },
    config(config) {
      this.options = { ...config };
      this.schedule({ replot: false });
    }
  },
  beforeDestroy() {
    events.forEach(event => this.$el.removeAllListeners(event.completeName));
    Plotly.purge(this.$el);
  },
  methods: {
    ...methods,
    onResize() {
      Plotly.Plots.resize(this.$el);
    },
    schedule(context) {
      const { scheduled } = this;
      if (scheduled) {
        scheduled.replot = scheduled.replot || context.replot;
        return;
      }
      this.scheduled = context;
      this.$nextTick(() => {
        const {
          scheduled: { replot }
        } = this;
        this.scheduled = null;
        if (replot) {
          this.react();
          return;
        }
        this.relayout(this.innerLayout);
      });
    },
    toImage(options) {
      const allOptions = Object.assign(this.getPrintOptions(), options);
      return Plotly.toImage(this.$el, allOptions);
    },
    downloadImage(options) {
      const filename = `plot--${new Date().toISOString()}`;
      const allOptions = Object.assign(this.getPrintOptions(), { filename }, options);
      return Plotly.downloadImage(this.$el, allOptions);
    },
    getPrintOptions() {
      const { $el } = this;
      return {
        format: "png",
        width: $el.clientWidth,
        height: $el.clientHeight
      };
    },
    react() {
      Plotly.react(this.$el, this.data, this.innerLayout, this.options);
    }
  }
})
