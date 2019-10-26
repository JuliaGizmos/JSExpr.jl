# Overload interpolate for observables so that we can access the observable
# itself during deparse. This also has the side effect of making interpolating
# observables without dereferencing them an error, which is probably a good
# thing.
struct _ObservableJSNode <: JSNode
    obs::AbstractObservable
end
interpolate(obs::AbstractObservable) = _ObservableJSNode(obs)
function deparse(::_ObservableJSNode)
    error(
        "Cannot implicitly convert observable in JSExpr " *
        "(did you mean to dereference the observable?)."
    )
end

function deparse_getindex(obs_node::_ObservableJSNode)
    obs = obs_node.obs
    if !haskey(WebIO.observ_id_dict, obs)
        error("No scope associated with observable being interpolated")
    end
    scope_weakref, name = WebIO.observ_id_dict[obs]
    scope = scope_weakref.value
    if scope === nothing
        error("The scope of the observable being interpolated no longer exists.")
    end

    obsinfo = Dict(
        "type" => "observable",
        "scope" => WebIO.scopeid(scope),
        "name" => name,
        "id" => WebIO.obsid(obs),
    )
    return js"WebIO.getval($obsinfo)"
end

function deparse_setindex(obs::AbstractObservable, value)
    error("Not implemented!")
end
