[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]


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
    youngs_modulus = 73000000000.0
    poissons_ratio = 0.34
  []
  [stress]
    type = ComputeLinearElasticStress
  []
  [thermal_expansion_strain]
    type = ComputeThermalExpansionEigenstrain
    stress_free_temperature = 200
    thermal_expansion_coeff = 2.2e-05
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
  input_files = input_thermal.i

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
  end_time = 3000
  dt = 100
[]


[Postprocessors]
  [avg_stress_xx]
    type = ElementAverageValue
    variable = stress_xx
  []
[]

[Outputs]
  exodus = false
  csv = true
  execute_on = 'FINAL'
[]