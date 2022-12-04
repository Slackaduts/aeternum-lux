function TweenManager() constructor {
    tweens = [];

    // Start a new tween
    add = function(_tween) {
        array_push(tweens, _tween);
    }

    // Run the tween manager
    run = function() {
        // Has a tween finished?
        if (array_length(tweens) > 0 && tweens[0].run()) {

            // Perform any special ending actions
            tweens[0].onEnd();

            // Remove finished tween
            array_delete(tweens, 0, 1);
        }
    }

    // Stop the current tween and all upcoming tweens
    clear = function() {
            tweens = [];
    }
}


function NumberTween(_duration, _start = 0, _finish = 0, _property = function() { }, _shape = "Linear", _onEnd = function() { }) constructor {
    // Where does the tween start? Where will it end?
    start = _start;
    finish = _finish;

    // How long does the tween take?
    time = 0;
    duration = _duration;

    // What does the tween affect?
    property = method(other, _property);
    shape = animcurve_get_channel(anim_tweens, _shape);

    // What happens when the tween is over?
    onEnd = _onEnd;

    // Run the tween
    run = function() {
        time = min(time + 1, duration);

        // If start is an array, then we are tweening multiple values
        if (is_array(start)) {
            var value = [];
            for (var i = 0; i < array_length(start); i++) {
                value[i] = lerp(start[i], finish[i], animcurve_channel_evaluate(shape, time / duration));
            }
            property(value);
        }
        else {
            property(lerp(start, finish, animcurve_channel_evaluate(shape, time / duration)));
        }

        // When time equals duration, the tween is over!
        return time == duration;
    }
}