import easyvvuq as uq
import chaospy as cp
from pathlib import Path
import matplotlib.pyplot as plt
import pandas as pd

params_mechanical = {
    "E": {"type": "float", "default": 70e9},
    "nu": {"type": "float", "default": 0.34},
    "alpha": {"type": "float", "default": 2.3e-5},
}

params_thermal = {
    "rho": {"type": "float", "default": 2700},
    "cp": {"type": "float", "default": 0.897},
    "lambda": {"type": "float", "default": 237},
}

params = {**params_mechanical, **params_thermal}

script_dir = Path(__file__).resolve().parent

# 2. Chemins absolus vers le template .i et l'exécutable lion-opt
template_path_mechanical = script_dir / "DCB_ThermalExpansion_mechanics_UQ.i"

encoder_mechanical = uq.encoders.JinjaEncoder(
    template_fname=str(template_path_mechanical),
    target_filename="input_mechanical.i",
)

template_path_thermal = script_dir / "DCB_ThermalExpansion_heattransfer_UQ.i"

encoder_thermal = uq.encoders.JinjaEncoder(
    template_fname=str(template_path_thermal),
    target_filename="input_thermal.i",
)

decoder = uq.decoders.SimpleCSV(
    target_filename="input_mechanical_out.csv", output_columns=["avg_stress_xx"]
)


lion_exec = script_dir.parents[1] / "lion-opt"
execute = uq.actions.ExecuteLocal(f"{lion_exec} -i input_mechanical.i")

actions = uq.actions.Actions(
    uq.actions.CreateRunDirectory("/tmp"),
    uq.actions.Encode(encoder_mechanical),
    uq.actions.Encode(encoder_thermal),
    execute,
    uq.actions.Decode(decoder),
)

campaign = uq.Campaign(name="dcb_thermo_mech_uq", params=params, actions=actions)

# Définition des incertitudes (ex: loi normale sur E, uniforme sur nu)
vary = {
    "E": cp.Normal(70e9, 3.0e9),
    "nu": cp.Normal(0.34, 0.02),
    "alpha": cp.Normal(2.3e-5, 0.1e-5),
    "rho": cp.Normal(2700.0, 10.0),
    "cp": cp.Normal(0.897, 0.05),
    "lambda": cp.Normal(237.0, 5.0),
}

# Échantillonnage PCE (ordre 3 -> très précis avec peu de simulations MOOSE)
sampler = uq.sampling.PCESampler(vary=vary, polynomial_order=2, sparse=True)
campaign.set_sampler(sampler)

campaign.execute(
    sequential=False
).collate()  # nsamples=sampler.n_samples, sequential=False
df_results = campaign.get_collation_result()
print(df_results.head(10))

results = campaign.analyse(qoi_cols=["avg_stress_xx"])

print("Stress mean :", results.describe("avg_stress_xx", "mean"))
print("Standard deviation :", results.describe("avg_stress_xx", "std"))
# print("Indices de Sobol (1er ordre) :", results.sobols_first()["fleche"])
df_results = pd.DataFrame(
    [
        {
            "Stress impulse mean": results.describe("avg_stress_xx", "mean"),
            "Standard deviation": results.describe("avg_stress_xx", "std"),
        }
    ]
)
df_results.to_csv(script_dir / "UQ_prop_results.csv", index=False)


results.plot_sobols_treemap("avg_stress_xx", figsize=(10, 10))
plt.axis("off")
plt.savefig(script_dir / "sobol_treemap.png", dpi=300, bbox_inches="tight")
plt.show()
