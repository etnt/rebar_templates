%    -*- Erlang -*- 
%    File:	rest_appmod.erl
%    Author:	Nadia Mohedano Troyano
%
%  Adapted to SimpleBridge by etnt@redhoterlang.com
%
-module({{appid}}_web_index).
-export([dispatch/1]).

-include("{{appid}}.hrl").
-include_lib("yaws/include/yaws_api.hrl").

dispatch(#controller{}) ->
    throw({ssi, {ssi, "/index.html", "%%", []}}).

