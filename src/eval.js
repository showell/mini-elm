return (function () {
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

        return function() {
            return "cannot find List function: " + name;
        }
    }

    function ev(c, expr) {
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
                return lambda([], initParams, rec.body);

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
        let context = [
            { name: 'n', val: 55 }
        ];
        if (expr.$ === 'Ok') {
            return ev(context, expr.a);
        } else {
            return 'error';
        }
    }

    return _Debug_toString(result(ast));

}());
