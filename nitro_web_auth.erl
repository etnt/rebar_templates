%% @author {{name}} {{email}}
%% @copyright YYYY {{name}}.

%% @doc The terminating leg of the OpenID authentication.

-module({{appid}}_web_auth).

-export([main/0]).

-include_lib ("nitrogen/include/wf.hrl").


main() -> 
    try
        Dict = wf:session(eopenid_dict),
        RequestBridge = wf_context:request_bridge(),
        RawPath = RequestBridge:uri(),
        %% assertion
        true = eopenid_v1:verify_signed_keys(RawPath, Dict),
        ClaimedId = eopenid_lib:out("openid.claimed_id", Dict),
        wf:user(ClaimedId),
        wf:session(authenticated, true),
        wf:redirect("/")
    catch
	_:_Err ->
            io:format("~p: Error(~p), ~p~n",[?MODULE,_Err,erlang:get_stacktrace()]),
            % FIXME a better way of presenting errors (jGrowl ?)
            wf:redirect("/error?emsg=authentication_failed")
    end.

	
