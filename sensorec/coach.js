"use strict";
var tip_metadata = {
    'sample_size': 15,
    'thresholds': [
                   {
                   'param': 'bounce',
                   'display_name': 'bounce',
                   'min': 10000,
                   'max': 50000,
                   'priority': 2
                   },
                   {
                   'param': 'pelvic_rot_x',
                   'display_name': 'pelvic rotation',
                   'max': 10,
                   'priority': 1
                   }
                   ],
    'tips': [
             {
             'id': 1,
             'text': 'Keep your midsection engaged, like someone is going to punch you.',
             'triggers': [
                          {
                          'parameter': 'pelvic_rot_x',
                          'threshold': 'max',
                          'priority': 1
                          }
                          ]
             },
             {
             'id': 2,
             'text': 'You\'re running one leg at a time.',
             'triggers': [
                          {
                          'parameter': 'pelvic_rot_x',
                          'threshold': 'max',
                          'priority': 2
                          },
                          {
                          'parameter': 'bounce',
                          'threshold': 'min',
                          'priority': 1
                          }
                          ]
             }
             ]
};
/*
 Utility functions
 */
if(LOG === undefined){
    LOG = function(s){
        console.log(s);
    }
};

/*
 tip metadata mgr
 */
var metadata_mgr = function (tip_metadata) {
    var my_metadata = JSON.parse(JSON.stringify(tip_metadata));
    var thresholds;
    var sample_size = my_metadata.sample_size;
    var tips = {
        'cadence': {
            'min_tips': [
            ],
            'max_tips': [
            ]
        },
        'bounce': {
            'min_tips': [
            ],
            'max_tips': [
            ]
        },
        'lurch': {
            'min_tips': [
            ],
            'max_tips': [
            ]
        },
        'pelvic_rot_x': {
            'min_tips': [
            ],
            'max_tips': [
            ]
        },
        'pelvic_rot_y': {
            'min_tips': [
            ],
            'max_tips': [
            ]
        },
        'pelvic_rot_z': {
            'min_tips': [
            ],
            'max_tips': [
            ]
        },
        'stride': {
            'min_tips': [
            ],
            'max_tips': [
            ]
        },
        'ground_contact_t': {
            'min_tips': [
            ],
            'max_tips': [
            ]
        }
    };
    tip_metadata.tips.forEach(function (tip, idx, tip_array) {
                              tip.triggers.forEach(function (trigger, idx, trigger_array) {
                                                   var param = trigger.parameter;
                                                   if (trigger.threshold === 'min') {
                                                   tips[param].min_tips.push({
                                                                             'id': tip.id,
                                                                             'priority': trigger.priority,
                                                                             'text': tip.text
                                                                             });
                                                   }
                                                   else {
                                                   tips[param].max_tips.push({
                                                                             'id': tip.id,
                                                                             'priority': trigger.priority,
                                                                             'text': tip.text
                                                                             });
                                                   }
                                                   });
                              });
    //sort tips
    for (var tip_param in tips) {
        if (tips.hasOwnProperty(tip_param) && typeof tip_param !== 'function') {
            var value = tips[tip_param];
            var sort_fn = function (a, b) {
                if (a.priority < b.priority)
                    return - 1;
                else if (a.priority > b.priority)
                    return 1;
                else
                    return 0;
            };
            value.min_tips = value.min_tips.sort(sort_fn);
            value.max_tips = value.max_tips.sort(sort_fn);
        }
    };
    //sort thresholds
    var thresholds = JSON.parse(JSON.stringify(tip_metadata.thresholds));
    thresholds = thresholds.sort(function (a, b) {
                                 if (a.priority < b.priority) {
                                 return - 1
                                 }
                                 else if (a.priority > b.priority) {
                                 return 1;
                                 }
                                 else {
                                 return 0;
                                 }
                                 });
    LOG('threshold=' + JSON.stringify(thresholds));
    LOG('tip=' + JSON.stringify(tips));
    return {
        /*
         returns the tip matrix
         */
        'getTipsMatrix': function () {
            return JSON.parse(JSON.stringify(tips));
        },
        /*
         returns the thresholds
         */
        'getThresholds': function () {
            return JSON.parse(JSON.stringify(thresholds));
        },
        /*
         returns the sample size
         */
        'sample_size': sample_size
    };
}(tip_metadata); //end metadata_mgr


/*
 Run data mgr
 */
var run_data_mgr = function () {
    var dataPoints = [
    ];
    var avg;
    var tips_matrix = metadata_mgr.getTipsMatrix();
    var sample_avg;
    var sample_pts = [
    ];
    var avgImpl = function (dataPoints) {
        return dataPoints.reduce(function (avg, currVal, idx, array) {
                                 var newAvg = {
                                 };
                                 newAvg.cadence = (avg.cadence * idx + currVal.cadence) / (idx + 1);
                                 newAvg.bounce = (avg.bounce * idx + currVal.bounce) / (idx + 1);
                                 newAvg.lurch = (avg.lurch * idx + currVal.lurch) / (idx + 1);
                                 newAvg.pelvic_rot_x = (avg.pelvic_rot_x * idx + currVal.pelvic_rot_x) / (idx + 1);
                                 newAvg.pelvic_rot_y = (avg.pelvic_rot_y * idx + currVal.pelvic_rot_y) / (idx + 1);
                                 newAvg.pelvic_rot_z = (avg.pelvic_rot_z * idx + currVal.pelvic_rot_z) / (idx + 1);
                                 newAvg.stride = (avg.stride * idx + currVal.stride) / (idx + 1);
                                 newAvg.ground_contact_t = (avg.ground_contact_t * idx
                                                            + currVal.ground_contact_t) / (idx + 1);
                                 LOG('avg bouce=' + avg.bounce + ' avg pelvic_rot_x=' + avg.pelvic_rot_x +
                                     ' idx=' + idx);
                                 LOG('newAvg bouce=' + newAvg.bounce + ' newAvg pelvic_rot_x=' +
                                     newAvg.pelvic_rot_x);
                                 return newAvg;
                                 });
    }
    return {
        /*
         Calculates avg since th begining of the run
         */
        'calcAvg': function () {
            LOG('calcAvg');
            return avgImpl(dataPoints);
        }, //end calcAvg
        /*
         Calculates sample avg
         */
        'calcSampleAvg': function () {
            LOG('calcSampleAvg');
            return avgImpl(sample_pts);
        },
        /*
         Adds a data point and returns tips if there are any.
         */
        'addDataPoint': function (dp) {
            LOG('addDataPoint():START;dp=' + JSON.stringify(dp));
            if (dp.t === undefined || dp.cadence === undefined || dp.bounce === undefined || dp.lurch === undefined
                || dp.pelvic_rot_x === undefined || dp.pelvic_rot_y === undefined || dp.pelvic_rot_z === undefined
                || dp.stride === undefined || dp.ground_contact_t === undefined) {
                LOG('bad dp=' + JSON.stringify(dp));
                throw {
                    'name': 'BadInput',
                    'message': 'datapoint is missing a required field; pt=' + dp
                };
            }
            var tips = [
            ];
            dataPoints.push(dp);
            sample_pts.push(dp);
            if (sample_pts.length >= metadata_mgr.sample_size) {
                sample_avg = this.calcSampleAvg();
                var thresholds = metadata_mgr.getThresholds();
                for(var i=0; i < thresholds.length; i++){
                    var threshold = thresholds[i];
                    var param = threshold.param;
                    var min = (threshold.min == undefined) ? Number.NEGATIVE_INFINITY : threshold.min;
                    var max = (threshold.max == undefined) ? Number.POSITIVE_INFINITY : threshold.max;
                    LOG('checking param=' + param + ' threshold.min=' + threshold.min +
                        ' threshold.max=' + threshold.max + ' avg=' + sample_avg[param]);
                    if (sample_avg[param] < min) {
                        var s = 'Your ' + threshold.display_name + ' is too low.';
                        if(tips_matrix[param].min_tips.length >0){
                            s += tips_matrix[param].min_tips[0].text;
                        }
                        tips.push(s);
                        break;
                    }
                    else if (sample_avg[param] > max) {
                        var s = 'Your ' + threshold.display_name + ' is too high.';
                        if(tips_matrix[param].max_tips.length >0){
                            s += tips_matrix[param].max_tips[0].text;
                        }
                        tips.push(s);
                        break;
                    }
                    else{
                        continue;
                    }
                }
                
                sample_pts = [];
            }
            return tips;
        }
    };
}();


//TEST CODE
var test_data = [
                 {
                 't': 1,
                 'cadence': 111.11,
                 'bounce': 222.22,
                 'lurch': 333.33,
                 'pelvic_rot_x': 30,
                 'pelvic_rot_y': 0,
                 'pelvic_rot_z': 0,
                 'stride': 555.55,
                 'ground_contact_t': 666.66
                 },
                 {
                 't': 2,
                 'cadence': 111.11,
                 'bounce': 222.22,
                 'lurch': 333.33,
                 'pelvic_rot_x': 30,
                 'pelvic_rot_y': 0,
                 'pelvic_rot_z': 0,
                 'stride': 555.55,
                 'ground_contact_t': 666.66
                 },
                 {
                 't': 3,
                 'cadence': 111.11,
                 'bounce': 222.22,
                 'lurch': 333.33,
                 'pelvic_rot_x': 30,
                 'pelvic_rot_y': 0,
                 'pelvic_rot_z': 0,
                 'stride': 555.55,
                 'ground_contact_t': 666.66
                 },
                 {
                 't': 4,
                 'cadence': 111.11,
                 'bounce': 222.22,
                 'lurch': 333.33,
                 'pelvic_rot_x': 30,
                 'pelvic_rot_y': 0,
                 'pelvic_rot_z': 0,
                 'stride': 555.55,
                 'ground_contact_t': 666.66
                 },
                 {
                 't': 5,
                 'cadence': 111.11,
                 'bounce': 222.22,
                 'lurch': 333.33,
                 'pelvic_rot_x': 30,
                 'pelvic_rot_y': 0,
                 'pelvic_rot_z': 0,
                 'stride': 555.55,
                 'ground_contact_t': 666.66
                 },
                 {
                 't': 6,
                 'cadence': 111.11,
                 'bounce': 222.22,
                 'lurch': 333.33,
                 'pelvic_rot_x': 30,
                 'pelvic_rot_y': 0,
                 'pelvic_rot_z': 0,
                 'stride': 555.55,
                 'ground_contact_t': 666.66
                 },
                 {
                 't': 7,
                 'cadence': 111.11,
                 'bounce': 222.22,
                 'lurch': 333.33,
                 'pelvic_rot_x': 30,
                 'pelvic_rot_y': 0,
                 'pelvic_rot_z': 0,
                 'stride': 555.55,
                 'ground_contact_t': 666.66
                 },
                 {
                 't': 8,
                 'cadence': 111.11,
                 'bounce': 222.22,
                 'lurch': 333.33,
                 'pelvic_rot_x': 30,
                 'pelvic_rot_y': 0,
                 'pelvic_rot_z': 0,
                 'stride': 555.55,
                 'ground_contact_t': 666.66
                 },
                 {
                 't': 9,
                 'cadence': 111.11,
                 'bounce': 222.22,
                 'lurch': 333.33,
                 'pelvic_rot_x': 30,
                 'pelvic_rot_y': 0,
                 'pelvic_rot_z': 0,
                 'stride': 555.55,
                 'ground_contact_t': 666.66
                 },
                 {
                 't': 10,
                 'cadence': 111.11,
                 'bounce': 222.22,
                 'lurch': 333.33,
                 'pelvic_rot_x': 10,
                 'pelvic_rot_y': 0,
                 'pelvic_rot_z': 0,
                 'stride': 555.55,
                 'ground_contact_t': 666.66
                 }
                 ];
function test() {
    test_data.forEach(function (element, idx, array) {
                      var tips = run_data_mgr.addDataPoint(element);
                      tips.forEach(function(item, idx, array){
                                   LOG('tip=' + item);
                                   });
                      });
    //   var avg = run_data_mgr.calcAvg();
    //   LOG('Run Average:avg bouce=' + avg.bounce + ' avg pelvic_rot_x=' + avg.pelvic_rot_x);
}

//test();

