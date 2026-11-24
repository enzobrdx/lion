[Mesh]
  [poutre]
    type = FileMeshGenerator
    file = DCB_mesh_in.e
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
    thermal_conductivity = 237.0
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
  end_time = 6000
  dt = 100
[]


[Outputs]
  exodus = true
[]
