[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
  rotations = 'rot_x rot_y rot_z'
[]

b = 0.9990000000000001
h = 1.001
L = 20.0

[Mesh]
  [poutre]
    type = GeneratedMeshGenerator
    dim = 1
    nx = 1
    xmin = 0.0
    xmax = ${L}
  []
[]

[Physics/SolidMechanics/LineElement/QuasiStatic]
  [all]
    add_variables = true
    area = ${fparse b * h}
    Iy = ${fparse h * b^3 / 12.0}
    Iz = ${fparse b * h^3 / 12.0}
    y_orientation = '0 1 0'
  []
[]

[Materials]
  [elasticity]
    type = ComputeElasticityBeam
    youngs_modulus = 73000000000.0
    poissons_ratio = 0.33
  []
  [stress]
    type = ComputeBeamResultants
  []
[]

[Kernels]
  [Pressure]
    type = BodyForce
    variable = disp_y
    value = -1000000.0
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
  [left_z]
    type = DirichletBC
    boundary = left
    variable = disp_z
    value = 0.0
  []
  [leftrot_z]
    type = DirichletBC
    boundary = left
    variable = rot_z
    value = 0.0
  []
  [leftrot_y]
    type = DirichletBC
    boundary = left
    variable = rot_y
    value = 0.0
  []
  [leftrot_x]
    type = DirichletBC
    boundary = left
    variable = rot_x
    value = 0.0
  []
[]


[Executioner]
  type = Steady
  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
[]

[Postprocessors]
  [fleche]
    type = PointValue
    point = '${L} 0 0'
    variable = disp_y
  []
[]

[Outputs]
  [csv]
    type = CSV
    file_base = input_out
    execute_on = 'FINAL'
  []
[]