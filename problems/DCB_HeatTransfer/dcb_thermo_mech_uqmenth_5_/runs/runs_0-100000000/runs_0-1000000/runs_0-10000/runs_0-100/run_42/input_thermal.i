[Mesh]
  [poutre]
    type = GeneratedMeshGenerator
    elem_type = HEX8
    dim = 3
    nz = 1
    nx = 10
    ny = 1
    xmin = 0.0
    xmax = 20.0
    ymin = 0.0
    ymax = 1.0
    zmin = 0.0
    zmax = 1.0
  []
[]

[Variables]
  [T]
    initial_condition = 200.0
  []
[]

[Kernels]
  [heat_conduction]
    type = HeatConduction
    variable = T
  []
  [time_derivative]
    type = HeatConductionTimeDerivative
    variable = T
  []
[]

[Materials]
  [thermal]
    type = HeatConductionMaterial
    thermal_conductivity = 231.99999999999997
    specific_heat = 0.897
  []
  [density]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = 2700.0
  []
[]

[BCs]
  [t_right]
    type = FunctionDirichletBC
    variable = T
    function = '400'
    boundary = 'right'
  []
[]

[Executioner]
  type = Transient
  end_time = 3000
  dt = 100
[]


[Outputs]
  exodus = true
[]