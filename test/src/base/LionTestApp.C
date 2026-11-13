//* This file is part of the MOOSE framework
//* https://mooseframework.inl.gov
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#include "LionTestApp.h"
#include "LionApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"

InputParameters
LionTestApp::validParams()
{
  InputParameters params = LionApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  params.set<bool>("use_legacy_initial_residual_evaluation_behavior") = false;
  return params;
}

LionTestApp::LionTestApp(const InputParameters & parameters) : MooseApp(parameters)
{
  LionTestApp::registerAll(
      _factory, _action_factory, _syntax, getParam<bool>("allow_test_objects"));
}

LionTestApp::~LionTestApp() {}

void
LionTestApp::registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs)
{
  LionApp::registerAll(f, af, s);
  if (use_test_objs)
  {
    Registry::registerObjectsTo(f, {"LionTestApp"});
    Registry::registerActionsTo(af, {"LionTestApp"});
  }
}

void
LionTestApp::registerApps()
{
  registerApp(LionApp);
  registerApp(LionTestApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
LionTestApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  LionTestApp::registerAll(f, af, s);
}
extern "C" void
LionTestApp__registerApps()
{
  LionTestApp::registerApps();
}
