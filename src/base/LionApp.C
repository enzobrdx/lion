#include "LionApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
LionApp::validParams()
{
  InputParameters params = MooseApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  params.set<bool>("use_legacy_initial_residual_evaluation_behavior") = false;
  return params;
}

LionApp::LionApp(const InputParameters & parameters) : MooseApp(parameters)
{
  LionApp::registerAll(_factory, _action_factory, _syntax);
}

LionApp::~LionApp() {}

void
LionApp::registerAll(Factory & f, ActionFactory & af, Syntax & syntax)
{
  ModulesApp::registerAllObjects<LionApp>(f, af, syntax);
  Registry::registerObjectsTo(f, {"LionApp"});
  Registry::registerActionsTo(af, {"LionApp"});

  /* register custom execute flags, action syntax, etc. here */
}

void
LionApp::registerApps()
{
  registerApp(LionApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
LionApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  LionApp::registerAll(f, af, s);
}
extern "C" void
LionApp__registerApps()
{
  LionApp::registerApps();
}
