function watchPlots(model, observe = true, parentSelector = '') {
    if (parentSelector != '') {
        let parent = document.querySelector(parentSelector)
        let plotNodes = parent.querySelectorAll('.js-plotly-plot')
        plotNodes.forEach(function(gd) { watchPlot(gd, model) })
    }

    if (observe) {
        sentinel.on('.js-plotly-plot', function(gd) { window.watchPlot(gd, model) })
    }
}

function watchPlot(gd, model) {
    syncList = [...gd.classList].filter(x => x.startsWith('sync_'))
    syncList.forEach(function(c) { watchGraphDiv(gd, model, c.match(/sync_(.*)/)[1]) })
}

function watchGraphDiv(gd, model, prefix) {
    console.info('Syncing plot of class \'' + gd.className + '\' to ' + model.$el.id + '.' + prefix)
    gd.on("plotly_selected", function (data) {
        var filteredEventData = filterEventData(gd, data, 'selected')
        if (!filteredEventData.isNil) { model[prefix + '_selected'] = filteredEventData.out }
    })

    gd.on("plotly_deselect", function () {
        model[prefix + '_selected'] = {}
    })

    gd.on("plotly_hover", function (data) {
        var filteredEventData = filterEventData(gd, data, 'hover')
        if (!filteredEventData.isNil) { model[prefix + '_hover'] = filteredEventData.out }
    })

    gd.on("plotly_unhover", function () {
        model[prefix + '_hover'] = {}
    })

    gd.on("plotly_click", function (data) {
        var filteredEventData = filterEventData(gd, data, 'click')
        if (!filteredEventData.isNil) { model[prefix + '_click'] = filteredEventData.out }
    })

    gd.on("plotly_relayout", function (data) {
        var filteredEventData = filterEventData(gd, data, 'relayout')
        if (!filteredEventData.isNil) { model[prefix + '_relayout'] = filteredEventData.out }
    })

    gd.onclick = function (event) {
        var layout = gd._fullLayout
        if (layout.hasOwnProperty('xaxis')) {
            br = gd.getBoundingClientRect()
            x = layout.xaxis.p2c(event.x - layout.margin.l - br.x)
            y = layout.yaxis.p2c(event.y - layout.margin.t - br.y)
            msg = {cursor: {x: x, y: y}}
        } else {
            if (layout.hasOwnProperty('geo')) {
                geo = layout.geo
            } else if (layout.hasOwnProperty('mapbox')) {
                geo = layout.mapbox
            } else {
                return
            }
            x = geo._subplot.xaxis.p2c()
            y = geo._subplot.yaxis.p2c()
            msg = {cursor: {lon: x, lat: y}}
        }
        model[prefix + '_click'] = msg
    }
}

function type(obj) {
    return typeof obj
}

function contains(item, list) {
    var idx = 0;
    while (idx < list.length) {
        if (list[idx] === item) {
            return true;
        }
      idx += 1;
    }
    return false;
}

function has(key, obj) {
    return obj.hasOwnProperty(key)
}

var isNil = function isNil(obj) {
    return obj == null
}

function filter(fn, obj) {
    for (key in obj) {
        if (!fn(obj[key])) { delete obj[key] }
    }
    return obj
}

function filterEventData(gd, eventData, event) {
    let filteredEventData;
    if (contains(event, ['click', 'hover', 'selected'])) {
        const points = [];

        if (isNil(eventData)) {
            return {out: null, isNil: true};
        }

        /*
        * remove `data`, `layout`, `xaxis`, etc
        * objects from the event data since they're so big
        * and cause JSON stringify ciricular structure errors.
        *
        * also, pull down the `customdata` point from the data array
        * into the event object
        */
        const data = gd.data;
        for(let i=0; i < eventData.points.length; i++) {
            const fullPoint = eventData.points[i];
            const pointData = filter(function(o) {
                return !contains(type(o), ['object', 'array'])
            }, fullPoint);
            if (has('curveNumber', fullPoint) &&
                has('pointNumber', fullPoint) &&
                has('customdata', data[pointData.curveNumber])
            ) {
                pointData['customdata'] = data[
                    pointData.curveNumber
                ].customdata[fullPoint.pointNumber];
            }

            // specific to histogram. see https://github.com/plotly/plotly.js/pull/2113/
            if (has('pointNumbers', fullPoint)) {
                pointData.pointNumbers = fullPoint.pointNumbers;
            }

            points[i] = pointData;

        }
        filteredEventData = {points}
    } else if (event === 'relayout') {
        /*
        * relayout shouldn't include any big objects
        * it will usually just contain the ranges of the axes like
        * "xaxis.range[0]": 0.7715822247381828,
        * "xaxis.range[1]": 3.0095292008680063`
        */
        filteredEventData = eventData;
    }
    if (has('range', eventData)) {
        filteredEventData.range = eventData.range;
    }
    if (has('lassoPoints', eventData)) {
        filteredEventData.lassoPoints = eventData.lassoPoints;
    }
    return {
    out: filteredEventData,
    isnil: isNil(filteredEventData)
    };
};
