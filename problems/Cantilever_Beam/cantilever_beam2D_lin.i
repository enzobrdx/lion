[GlobalParams]
  displacements = 'disp_x disp_y'
[]


[Mesh]
  [poutre]
    type = GeneratedMeshGenerator
    elem_type = QUAD4
    dim = 2
    nx = 100
    ny = 5
    xmin = 0.0
    xmax = 20.0
    ymin = 0.0
    ymax = 1.0
  []
[]

[Variables]
  [strain_zz]
    order = FIRST
    family = LAGRANGE
  []
[]

[Physics/SolidMechanics/QuasiStatic]
  [all]
    add_variables = true
    strain = SMALL
    planar_formulation = WEAK_PLANE_STRESS
    out_of_plane_strain = strain_zz
  []
[]

[Materials]
  [elasticity]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 70e9
    poissons_ratio = 0.34
  []
  [stress]
    type = ComputeLinearElasticStress
  []
[]

[BCs]
  [left_y]
    type = DirichletBC
    boundary = left
    variable = disp_y
    value = 0.0
  []
  [left_x]
    type = DirichletBC
    boundary = left
    variable = disp_x
    value = 0.0
  []
  [Pressure]
    [top]
      boundary = top
      factor = 1000000
    []
  []
[]

#[Preconditioning]
 # [smp]
  #  type = SMP
   # full = true
  #[]
#[]

[Executioner]
  type = Steady
  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
[]

[Postprocessors]
  [fleche]
    type = PointValue
    point = '20 0.5 0.0'
    variable = disp_y
  []
[]

[Outputs]
  exodus = true
  csv = true
[]
