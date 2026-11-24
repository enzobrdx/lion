import subprocess
import re
import pandas as pd
import matplotlib.pyplot as plt

from pathlib import Path

E = 70e9
alpha = 2.3e-5
# File path of the problem
script_dir = Path(__file__).resolve().parent

df = pd.read_csv(script_dir / "DCB_ThermalExpansion_mechanics_out.csv")

df = df.drop(index=0).reset_index(drop=True)
plt.figure(figsize=(10, 6))

plt.plot(
    df["compute_temperature"],
    df["compute_stress"],
    marker="o",
    linewidth=2,
)

# 7. Adding the analytical solution
plt.axline(
    (200, 0),
    slope=-E * alpha,
    color="black",
    linestyle="--",
    linewidth=2,
    label="Analytical line",
)
plt.title(
    "stress vs temperature during a transient heat transfer",
    fontsize=13,
)
plt.xlabel("Temperature (K)", fontsize=11)
plt.ylabel("Stress (Pa)", fontsize=11)
plt.grid(True, which="both", linestyle=":", alpha=0.7)
plt.legend(loc="best", frameon=True)
plt.tight_layout()

# 9. Saving the plot
plt.savefig("stress_vs_temperature.png", dpi=300)
plt.show()
