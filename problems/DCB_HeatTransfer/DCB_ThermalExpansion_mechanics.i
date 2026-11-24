[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]


[Mesh]
  [poutre]
    type = FileMeshGenerator
    file = DCB_mesh_in.e
  []
[]

[AuxVariables]
  [T]
    initial_condition = 200.0
  []
[]

[Physics/SolidMechanics/QuasiStatic]
  [all]
    add_variables = true
    strain = SMALL
    #incremental = true
    eigenstrain_names = eigenstrain
    generate_output = 'stress_xx stress_yy stress_zz vonmises_stress'
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
  [thermal_expansion_strain]
    type = ComputeThermalExpansionEigenstrain
    stress_free_temperature = 200
    thermal_expansion_coeff = 2.3e-5
    temperature = T
    eigenstrain_name = eigenstrain
  []
[]

[BCs]
  [left_x]
    type = DirichletBC
    boundary = left
    variable = disp_x
    value = 0.0
  []
  [right_x]
    type = DirichletBC
    boundary = right
    variable = disp_x
    value = 0.0
  []
[]

[MultiApps/heat_transfer]
  type = TransientMultiApp
  input_files = DCB_ThermalExpansion_heattransfer.i

  # Couple at the end of each timestep
  execute_on = TIMESTEP_BEGIN

  no_restore = true
[]

[Transfers]
  [receive_Temperature]
    type = MultiAppCopyTransfer
    from_multi_app = heat_transfer
    source_variable = T
    variable = T
  []
[]

#[Preconditioning]
 # [smp]
  #  type = SMP
   # full = true
  #[]
#[]

[Executioner]
  type = Transient
  end_time = 6000
  dt = 100
[]


[Postprocessors]
  [compute_stress]
    type = PointValue
    point = '0 0 0'
    variable = stress_xx
  []
  [compute_temperature]
    type = ElementAverageValue
    variable = T
  []
[]


[Outputs]
  exodus = true
  csv = true
[]
