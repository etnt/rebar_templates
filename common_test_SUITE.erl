%% -*- mode: erlang; erlang-indent-level: 4 -*-
%%% --------------------------------------------------------------------
%% @author {{name}} {{email}}
%% @copyright YYYY {{name}}.
%%% @doc Test suites for the {{appid}}
%%% --------------------------------------------------------------------

-module({{appid}}_SUITE).

-export([ init_per_suite/1
        , end_per_suite/1
        , init_per_testcase/2
        , end_per_testcase/2
        , all/0
        , all/1
        ]).

-export([ start_stop/1
         ]).

%-include_lib("common_test/include/ct.hrl").

%% ---------------------------------------------------------------------
%% H E L P   M A C R O S
%% ---------------------------------------------------------------------
%% Introduce a variable scope
%-define(f(Body), (fun() -> Body end)()).

%% Useful macro for testing equality.
-define(EQ(T1,T2),
        ((fun() ->
                  try {T1, T2} of
                      {__EQ_Result, __EQ_Result}       -> ok;
                      {__EQ_T1_Result, __EQ_T2_Result} ->
                          exit({?LINE,{'EQ', __EQ_T1_Result, __EQ_T2_Result},
                                erlang:get_stacktrace()})
                  catch
                      _:__EQ_R -> exit({?LINE, __EQ_R, erlang:get_stacktrace()})
                  end
          end)())
       ).

-define(MATCH(Pattern,Expr),
        (begin
             Pattern =
                 (fun() ->
                          try Expr of
                              Pattern = __MATCH_Expr_Result ->
                                  %% The pattern matching here is done to
                                  %% muffle warnings about unused variables.
                                  Pattern = __MATCH_Expr_Result;
                              __MATCH_Expr_Result ->
                                  exit({?LINE,
                                        {'MATCH', ??Pattern,
                                         __MATCH_Expr_Result},
                                        erlang:get_stacktrace()})
                          catch
                              _:__MATCH_R ->
                                  exit({?LINE, __MATCH_R,
                                        erlang:get_stacktrace()})
                          end
                  end)(),
             ok
         end)
       ).

%% ---------------------------------------------------------------------
%% I N I T  &  S E T U P
%% ---------------------------------------------------------------------
init_per_suite(Config) when is_list(Config) ->
    Config.

end_per_suite(Config) when is_list(Config) ->
    ok.

init_per_testcase(TC,Config) ->
    ?MODULE:TC({init,Config}).

end_per_testcase(TC,Config) ->
    ?MODULE:TC({cleanup,Config}).

all() -> all(suite).

all(doc)   -> ["{{appid}} test suite.."];
all(suite) -> testcases(?MODULE).

testcases(Module) ->
  [F || {F,1} <- Module:module_info(exports), is_testcase(Module, F)].

is_testcase(Module, Function) ->
  is_testcase(Module, Function, suite).

is_testcase(_Module, all, _Suite)      -> false;
is_testcase(_Module, scenario, _Suite) -> false;
is_testcase(Module, Function, Suite)   -> [] =:= (catch Module:Function(Suite)).

%% Return a Config value
cval(Key,PropList) ->
    proplists:get_value(Key,PropList).


%% ---------------------------------------------------------------------
%% T E S T   S U I T E S
%% ---------------------------------------------------------------------
start_stop(suite)             -> [];

start_stop(doc)               -> ["Start and stop a {{appid}} server"];

start_stop({init,Config})     -> Config;

start_stop({cleanup, Config}) -> Config;

start_stop(Config)            ->

    true.

                  
    
    
