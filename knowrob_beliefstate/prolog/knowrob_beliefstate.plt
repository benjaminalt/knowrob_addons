/** <module> knowrob_beliefstate

  Copyright (C) 2017 Mihai Pomarlan

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
      * Redistributions of source code must retain the above copyright
        notice, this list of conditions and the following disclaimer.
      * Redistributions in binary form must reproduce the above copyright
        notice, this list of conditions and the following disclaimer in the
        documentation and/or other materials provided with the distribution.
      * Neither the name of the <organization> nor the
        names of its contributors may be used to endorse or promote products
        derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

  @author Mihai Pomarlan
  @license BSD
*/

:- begin_tests(knowrob_beliefstate).

%% :- use_module(library('jpl')).
:- use_module(library('lists')).
:- use_module(library('util')).
:- use_module(library('semweb/rdfs')).
:- use_module(library('owl_parser')).
:- use_module(library('owl')).
:- use_module(library('rdfs_computable')).
:- use_module(library('knowrob_owl')).
:- use_module(library('knowrob_paramserver')).
:- use_module(library('tf_prolog')).
:- use_module(library('random')).
%% :- use_module(library('thorin_ontologies')).
%% :- use_module(library('thorin_simulation')).

%% :- load_foreign_library('libkr_beliefstate.so').

:- owl_parser:owl_parse('package://thorin_ontologies/owl/thorin_parts.owl').
:- owl_parser:owl_parse('package://thorin_ontologies/owl/thorin_assemblages.owl').
:- owl_parser:owl_parse('package://thorin_ontologies/owl/thorin_parameters.owl').
:- owl_parser:owl_parse('package://thorin_simulation/owl/thorin_simulation.owl').
:- rdf_db:rdf_register_ns(knowrob, 'http://knowrob.org/kb/knowrob.owl#',  [keep(true)]).
:- rdf_db:rdf_register_ns(rdf, 'http://www.w3.org/1999/02/22-rdf-syntax-ns#', [keep(true)]).
:- rdf_db:rdf_register_ns(owl, 'http://www.w3.org/2002/07/owl#', [keep(true)]).
:- rdf_db:rdf_register_ns(xsd, 'http://www.w3.org/2001/XMLSchema#', [keep(true)]).
:- rdf_db:rdf_register_ns(paramserver, 'http://knowrob.org/kb/knowrob_paramserver.owl#',  [keep(true)]).
:- rdf_db:rdf_register_ns(assembly, 'http://knowrob.org/kb/knowrob_assembly.owl#',  [keep(true)]).
:- rdf_db:rdf_register_ns(beliefstate, 'http://knowrob.org/kb/knowrob_beliefstate.owl#',  [keep(true)]).
%% :- rdf_db:rdf_register_ns(beliefstate, 'http://knowrob.org/kb/knowrob_beliefstate.owl#',  [keep(true)]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% test get_object_color
test(get_object_color1) :-
  get_object_color('asd',B),
  B=[0.5, 0.5, 0.5, 1.0].

test(get_object_color2) :-
  get_object_color('http://knowrob.org/kb/thorin_simulation.owl#AxleHolder1',B),
  B=[1.0, 0.0, 0.0, 1.0].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% test get_object_transform
test(get_object_transform1) :-
  get_object_transform('http://knowrob.org/kb/thorin_simulation.owl#AccessoryHolder1', T),!,
  T=["map", "AccessoryHolder1", [-1.166, 1.457, 0.883], [0.0, 0.0, 0.0, 1.0]].

test(get_object_transform2) :-
  assert_object_at_location(_, 'http://knowrob.org/kb/thorin_simulation.owl#AccessoryHolder1', ["map", "AccessoryHolder1", [0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 1.0]]),
  get_object_transform('http://knowrob.org/kb/thorin_simulation.owl#AccessoryHolder1', T),!,
  T=["map", "AccessoryHolder1", [0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 1.0]].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% test create_transform
test(create_transform1) :- 
  knowrob_beliefstate:create_transform(["map", "AccessoryHolder1", [1.0, 2.0, 2.0], [1.0, 0.0, 0.0, 0.0]], T),
  rdf_has(T, 'http://knowrob.org/kb/knowrob_paramserver.owl#hasReferenceFrame', RefFrame),
  rdf_has(RefFrame, 'http://knowrob.org/kb/knowrob_paramserver.owl#hasValue', literal(type(xml:string, RefFrameValue))),
  RefFrameValue="map",
  rdf_has(T, 'http://knowrob.org/kb/knowrob_paramserver.owl#hasTargetFrame', TargetFrame),
  rdf_has(TargetFrame, 'http://knowrob.org/kb/knowrob_paramserver.owl#hasValue', literal(type(xml:string, TargetFrameValue))),
  TargetFrameValue="AccessoryHolder1",
  rdf_has(T, 'http://knowrob.org/kb/knowrob.owl#translation', literal(type(xml:string, Translation))),
  knowrob_math:parse_vector(Translation, TranslationValue),
  rdf_has(T, 'http://knowrob.org/kb/knowrob.owl#quaternion', literal(type(xml:string, Rotation))),
  knowrob_math:parse_vector(Rotation, RotationValue),
  TranslationValue=[1.0, 2.0, 2.0],
  RotationValue=[1.0, 0.0, 0.0, 0.0].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% test get_grasp_position
test(get_pre_grasp_position1) :-
  get_pre_grasp_position('left_gripper', 'http://knowrob.org/kb/thorin_simulation.owl#Axle1', 'http://knowrob.org/kb/thorin_parameters.owl#TopGraspCenterReferencedPart', T),!,
  T=["left_gripper_tool_frame", "Axle1", [0.0, 0.0, 0.116], [1.0, 0.0, 0.0, 0.0]].
  
test(get_grasp_position1) :-
  get_grasp_position('left_gripper', 'http://knowrob.org/kb/thorin_simulation.owl#Axle1', 'http://knowrob.org/kb/thorin_parameters.owl#TopGraspCenterReferencedPart', T),!,
  T=["left_gripper_tool_frame", "Axle1", [0.0, 0.0, 0.0], [1.0, 0.0, 0.0, 0.0]].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
:- end_tests(knowrob_beliefstate).
