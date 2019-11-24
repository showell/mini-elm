/*
 * This is an experimental eval() loop for the elm-in-elm compiler.
 * It's running against an early version of elm-in-elm, so it only
 * handles the elm-in-elm constructs that were available in November 2019.
 *
 * It's almost certainly buggy, but it does handle some stuff pretty well.
 * You can try it out by following instructions in the README.
 *
 * It tries to stop runaway programs by counting numOperations.
 *
 * It also lets you call some standard library functions (such as all of
 * List.elm).  Those count as one operation each, so we can't detect
 * situations where library calls infinitely recurse.
 */
return (function () {
    var numOperations = 0;

    function truthy(expr) {
        return expr.a;
    }

    function just(x) {
        if (x.$ == 'Just') {
            return x.a;
        } else {
            return "";
        }
    }

    function lookup(c, module_, name) {
        for (var i = 0; i < c.length; ++i) {
            if (c[i].name === name) {
                return c[i].val;
            }
        }
        if (module_) {
            var mod = elmCore[module_];

            if (mod) {
                if (mod[name]) {
                    return mod[name]
                }
            }
        }

        console.log("bad context?", c, name);
        return function() {
            return "cannot find function: " + name;
        }
    }

    function ev(c, expr) {
        numOperations += 1;

        if (numOperations > 10000) {
            console.info("TOO MANY OPERATIONS! infinite recursion?");
            return "infinite recursion?";
        }

        function e(expr) {
            return ev(c, expr);
        }

        switch (expr.$) {
            case 'Call':
                var rec = expr.a;
                var f = e(rec.fn);

                try {
                    return f(e(rec.argument));
                } catch {
                    return function () {
                        return "problem with Call";
                    }
                }

            case 'Let':
                var rec = expr.a;
                var context = _List_toArray(
                    A2(
                        elmCore.List.map,
                        function (r) {
                            return {
                                name: r.name,
                                val: e(r.body)
                            };
                        },
                        rec.bindings
                    )
                );
                return ev(context, rec.body);

            case 'Lambda':
                function lambda(context, params, body) {
                    return function (arg) {
                        var newContext = [
                            { name: params[0], val: arg }
                        ].concat(context);

                        if (params.length == 1)  {
                            return ev(newContext, rec.body);
                        } else {
                            return lambda
                                ( newContext
                                , params.slice(1)
                                , body);
                        }
                    };
                }
                var rec = expr.a;
                var initParams = _List_toArray(rec._arguments);
                return lambda(c, initParams, rec.body);

            case 'If':
                var rec = expr.a;

                if (truthy(rec.test)) {
                    return e(rec.then_);
                } else {
                    return e(rec.else_);
                }

            case 'Int':
                return expr.a;

            case 'Bool':
                return expr.a;

            case 'Float':
                return expr.a;

            case 'Plus':
                return e(expr.a) + e(expr.b);

            case 'Var':
                return lookup(c, just(expr.a.module_), expr.a.name);

            case 'Argument':
                var name = expr.a;

                return lookup(c, "", name);

            case 'Cons':
                return _List_Cons
                    ( e(expr.a)
                    , e(expr.b)
                    );

            case 'List':
                let items = _List_toArray(expr.a);
                let evItems = A2(_JsArray_map, e, items);

                return _List_fromArray(evItems);

            default:
                return '??';
        }
    }

    function result(expr) {
        let context = [];
        if (expr.$ === 'Ok') {
            let val = ev(context, expr.a);
            console.info('numOperations', numOperations);
            return val;
        } else {
            return 'error';
        }
    }

    return _Debug_toString(result(ast));

}());
