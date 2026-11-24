import easyvvuq as uq
import chaospy as cp
from pathlib import Path
import matplotlib.pyplot as plt
import pandas as pd

params = {
    "E": {"type": "float", "default": 70e9},
    "nu": {"type": "float", "default": 0.34},
    "lenght": {"type": "float", "default": 20.0},
    "lenght_y": {"type": "float", "default": 1.0},
    "lenght_z": {"type": "float", "default": 1.0},
}

script_dir = Path(__file__).resolve().parent

# 2. Chemins absolus vers le template .i et l'exécutable lion-opt
template_path = script_dir / "cantilever_beam1D_UQ.i"

encoder = uq.encoders.JinjaEncoder(
    template_fname=str(template_path),
    target_filename="input.i",
)

decoder = uq.decoders.SimpleCSV(
    target_filename="input_out.csv", output_columns=["fleche"]
)


lion_exec = script_dir.parents[1] / "lion-opt"
execute = uq.actions.ExecuteLocal(f"{lion_exec} -i input.i")

actions = uq.actions.Actions(
    uq.actions.CreateRunDirectory("/tmp"),
    uq.actions.Encode(encoder),
    execute,
    uq.actions.Decode(decoder),
)

campaign = uq.Campaign(name="beam_uq", params=params, actions=actions)

# Définition des incertitudes (ex: loi normale sur E, uniforme sur nu)
vary = {
    "E": cp.Normal(70e9, 3.0e9),
    "nu": cp.Normal(0.33, 0.02),
    "lenght_y": cp.Normal(1, 1e-3),
    "lenght_z": cp.Normal(1, 1e-3),
    "lenght": cp.Normal(20, 1e-3),
}

# Échantillonnage PCE (ordre 3 -> très précis avec peu de simulations MOOSE)
sampler = uq.sampling.PCESampler(vary=vary, polynomial_order=3, sparse=True)
campaign.set_sampler(sampler)

campaign.execute(
    sequential=False
).collate()  # nsamples=sampler.n_samples, sequential=False
df_results = campaign.get_collation_result()
print(df_results.head(10))

results = campaign.analyse(qoi_cols=["fleche"])

print("Moyenne de la flèche :", results.describe("fleche", "mean"))
print("Écart-type :", results.describe("fleche", "std"))
# print("Indices de Sobol (1er ordre) :", results.sobols_first()["fleche"])
df_results = pd.DataFrame(
    [
        {
            "Deflection mean": results.describe("fleche", "mean"),
            "Standard deviation": results.describe("fleche", "std"),
        }
    ]
)
df_results.to_csv(script_dir / "UQ_prop_results.csv", index=False)


results.plot_sobols_treemap("fleche", figsize=(10, 10))
plt.axis("off")
plt.savefig(script_dir / "sobol_treemap.png", dpi=300, bbox_inches="tight")
plt.show()
