# ======================================================================

# Mode-I DCB delamination test, 2D plane strain, MOOSE solid_mechanics
#
# Geometry:   length L = 150, 
#             initial crack length a0 = 55, 
#             arm thickness h = 1.98 
# Layup:      unidirectional CFRP, fibres along x 
# Interface:  bilinear traction-separation (Camanho & Davila 2002)
#
# ======================================================================

L  = 150.0
a0 = 55.0
h  = 1.98    # half thickness (one arm)
d  = 8.0     # applied opening of each arm at t = 1

[Mesh]
  [msh]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = 0
    xmax = ${L}
    ymin = -${h}
    ymax = ${h}
    nx = 500           # 0.5 mm along the crack path
    ny = 14            
  []
  [bot]
    type = SubdomainBoundingBoxGenerator
    input = msh
    bottom_left = '0 -${h} 0'
    top_right = '${L} 0 0'
    block_id = 1
    block_name = 'bot'
  []
  [top]
    type = SubdomainBoundingBoxGenerator
    input = bot
    bottom_left = '0 0 0'
    top_right = '${L} ${h} 0'
    block_id = 2
    block_name = 'top'
  []
  [split]
    type = BreakMeshByBlockGenerator
    input = top
    # no block_pairs: every node on the mid-plane gets duplicated,
    # including the crack tip node at x = a0
  []
  [czm_zone]
    type = SideSetsFromBoundingBoxGenerator
    input = split
    included_boundaries = 'bot_top'
    boundary_new = 'czm_zone'
    bottom_left = '${a0} -${h} 0'
    top_right = '${L} ${h} 0'
    location = INSIDE
  []
  [load_bot]
    type = ExtraNodesetGenerator
    input = czm_zone
    coord = '0 -${h} 0'
    new_boundary = load_bot
  []
  [load_top]
    type = ExtraNodesetGenerator
    input = load_bot
    coord = '0 ${h} 0'
    new_boundary = load_top
  []
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Physics/SolidMechanics/QuasiStatic]
  [all]
    strain = FINITE
    planar_formulation = PLANE_STRAIN
    add_variables = true
    use_finite_deform_jacobian = true
    save_in = 'resid_x resid_y'
    generate_output = 'stress_xx stress_yy stress_xy'
  []
[]

[Physics/SolidMechanics/CohesiveZone]
  [czm]
    boundary = 'czm_zone'
    strain = FINITE
    generate_output = 'normal_traction tangent_traction normal_jump tangent_jump'
  []
[]

[Functions]
  [open]
    type = PiecewiseLinear
    x = '0    1     2'
    y = '0  ${d}    0'
  []
  [open_neg]
    type = PiecewiseLinear
    x = '0     1     2'
    y = '0  -${d}    0'
  []
[]

[AuxVariables]
  [resid_x]
  []
  [resid_y]
  []
  [damage]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[AuxKernels]
  [damage]
    type = MaterialRealAux
    variable = damage
    property = damage
    boundary = 'czm_zone'
    execute_on = timestep_end
  []
[]

[BCs]
  [fix_x]
    type = DirichletBC
    variable = disp_x
    boundary = right
    value = 0
    preset = true
  []
  [open_top]
    type = FunctionDirichletBC
    variable = disp_y
    boundary = load_top
    function = open
    preset = true
  []
  [open_bot]
    type = FunctionDirichletBC
    variable = disp_y
    boundary = load_bot
    function = open_neg
    preset = true
  []
[]

[Materials]
  [elasticity_tensor]
    type = ComputeElasticityTensor
    block = 'bot top'
    fill_method = symmetric9
    # C1111 C1122 C1133 C2222 C2233 C3333 C2323 C1313 C1212
    # from E1=150e3, E2=E3=11e3, G12=G13=6e3, G23=3.7e3, nu12=nu13=0.25, nu23=0.45
    C_ijkl = '1.5254e5 5.085e3 5.085e3 1.3963e4 6.376e3 1.3963e4 3.7e3 6.0e3 6.0e3'
  []
  [stress]
    type = ComputeFiniteStrainElasticStress
    block = 'bot top'
  []
  [czm_law]
    type = BiLinearMixedModeTraction
    boundary = 'czm_zone'
    penalty_stiffness = 1e6     # N/mm^3, "infinitely" stiff before onset
    GI_c = 0.268                # N/mm
    GII_c = 1.45                # N/mm
    normal_strength = 30.0      # MPa - below the true 60 MPa to smear
                                # the cohesive zone (Turon-style) 
    shear_strength = 90.0       # MPa
    eta = 1.45                  # B-K exponent
    mixed_mode_criterion = BK   # 
    viscosity = 1e-4            # raise to 1e-3 if the solve stalls after onset
    displacements = 'disp_x disp_y'
  []
[]

[Postprocessors]
  [opening]     # delta (displacement of the upper arm)
    type = NodalExtremeValue
    variable = disp_y
    boundary = load_top
    value_type = max
  []
  [load]        # P
    type = NodalSum
    variable = resid_y
    boundary = load_top
  []
  [czm_area]    
    type = AreaPostprocessor
    boundary = 'czm_zone'
    execute_on = initial
  []
[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  line_search = none
  automatic_scaling = true

  petsc_options_iname = '-pc_type -pc_factor_mat_solver_type'
  petsc_options_value = 'lu       superlu_dist'

  nl_rel_tol = 1e-7
  nl_abs_tol = 1e-8
  nl_max_its = 25
  l_max_its = 50

  start_time = 0.0
  end_time = 2.0
  dtmin = 1e-6

  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 2e-3
    optimal_iterations = 8
    growth_factor = 1.2
    cutback_factor = 0.5
  []
[]

[Outputs]
  exodus = true
  csv = true          # opening vs. load -> P-delta curve
  print_linear_residuals = false
[]
