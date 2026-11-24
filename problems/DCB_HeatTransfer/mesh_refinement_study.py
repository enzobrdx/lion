import subprocess
import re
import pandas as pd
import matplotlib.pyplot as plt

from pathlib import Path

# File path of the problem
script_dir = Path(__file__).resolve().parent

# Recover the list of .i files names in the directory
fichiers_i = [str(f) for f in script_dir.glob("*.i")]

# 1. Definition of mesh configurations to test (nx, ny, nz)
mesh_refinements = [(2, 1, 1), (4, 2, 2), (6, 3, 3), (8, 4, 4), (10, 5, 5)]

analytical_stress = -3.22e8

results = []
for i in range(len(fichiers_i)):
    print(f"--- Exécution pour le fichier {i} ---")

    # Reading of the moose file in the loop
    with open(fichiers_i[i], "r", encoding="utf-8") as f:
        template_content = f.read()

    # Test to refine the mesh depending on the dimensionality of the problem
    if "1D" in fichiers_i[i]:
        for nx, ny, nz in mesh_refinements:
            print(f"--- Exécution pour nx = {nx} ---")

            # 2. Dynamic modification of the mesh parameters directly in the .i file
            # Search of the nx, ny and nz lines to replace them
            modified_content = re.sub(r"nx\s*=\s*\d+", f"nx = {nx}", template_content)

            # Rewriting the modified content back to the file
            with open(fichiers_i[i], "w", encoding="utf-8") as f:
                f.write(modified_content)

            # 3. Moose running with subprocess
            cmd = ["../../lion-opt", "-i", fichiers_i[i]]
            subprocess.run(cmd, check=True)

            # 4. Recover the results from the csv file
            csv_filename = fichiers_i[i].replace(".i", "_out.csv")

            df = pd.read_csv(csv_filename)

            # Extract the last value of the fleche column
            fleche_max = df["fleche"].iloc[-1]

            L2_error = abs(fleche_max - fleche_analytique)

            results.append(
                {
                    "file name": fichiers_i[i],
                    "nx": nx,
                    "fleche": fleche_max,
                    "L2 error": L2_error,
                }
            )

    elif "2D" in fichiers_i[i]:
        for nx, ny, nz in mesh_refinements:
            print(f"--- Exécution pour nx = {nx} et ny = {ny} ---")

            # 2. Dynamic modification of the mesh parameters directly in the .i file
            # Search of the nx, ny and nz lines to replace them
            modified_content = re.sub(r"nx\s*=\s*\d+", f"nx = {nx}", template_content)
            modified_content = re.sub(r"ny\s*=\s*\d+", f"ny = {ny}", modified_content)

            # Rewriting the modified content back to the file
            with open(fichiers_i[i], "w", encoding="utf-8") as f:
                f.write(modified_content)

            # 3. Moose running with subprocess
            cmd = ["../../lion-opt", "-i", fichiers_i[i]]
            subprocess.run(cmd, check=True)

            # 4. Recover the results from the csv file
            csv_filename = fichiers_i[i].replace(".i", "_out.csv")

            df = pd.read_csv(csv_filename)

            # Extract the last value of the fleche column
            fleche_max = df["fleche"].iloc[-1]

            L2_error = abs(fleche_max - fleche_analytique)

            results.append(
                {
                    "file name": fichiers_i[i],
                    "nx": nx,
                    "fleche": fleche_max,
                    "L2 error": L2_error,
                }
            )
    else:
        for nx, ny, nz in mesh_refinements:
            print(f"--- Exécution pour nx = {nx}, ny = {ny} et nz = {nz}---")

            # 2. Dynamic modification of the mesh parameters directly in the .i file
            # Search of the nx, ny and nz lines to replace them
            modified_content = re.sub(r"nx\s*=\s*\d+", f"nx = {nx}", template_content)
            modified_content = re.sub(r"ny\s*=\s*\d+", f"ny = {ny}", modified_content)
            modified_content = re.sub(r"nz\s*=\s*\d+", f"nz = {nz}", modified_content)

            # Rewriting the modified content back to the file
            with open(fichiers_i[i], "w", encoding="utf-8") as f:
                f.write(modified_content)

            # 3. Moose running with subprocess
            cmd = ["../../lion-opt", "-i", fichiers_i[i]]
            subprocess.run(cmd, check=True)

            # 4. Recover the results from the csv file
            csv_filename = fichiers_i[i].replace(".i", "_out.csv")

            df = pd.read_csv(csv_filename)

            # Extract the last value of the fleche column
            compute_stress = df["compute_stress"].iloc[-1]

            L2_error = abs(compute_stress - analytical_stress)

            results.append(
                {
                    # "file name": fichiers_i[i],
                    "nx": nx,
                    "stress": compute_stress,
                    "L2 error": L2_error,
                }
            )


# 5. Display the results
df_results = pd.DataFrame(results)
# df_results = df_results.sort_values(by=["file name", "nx"])
print("\n=== Résumé de l'étude de convergence ===")
print(df_results)


# --- Plotting the deflection convergence ---
plt.figure(figsize=(10, 6))

# 6. Plotting one graph per file name (1D, 2Dlin, 2Dquad, 3Dlin, 3Dquad)
plt.plot(
    ["nx"],
    ["fleche"],
    marker="o",
    linewidth=2,
)

# 7. Adding the analytical solution
plt.axhline(
    y=analytical_stress,
    color="black",
    linestyle="--",
    linewidth=2,
    label=f"Analytical solution Euler-Bernoulli ({analytical_stress} m)",
)
# 8. Adding the title and labels
plt.title(
    "Mesh convergence analysis — Maximum deflection at the end of a beam", fontsize=13
)
plt.xlabel("Number of longitudinal elements (nx)", fontsize=11)
plt.ylabel("Maximum deflection disp_y (m)", fontsize=11)
plt.grid(True, which="both", linestyle=":", alpha=0.7)
plt.legend(loc="best", frameon=True)
plt.tight_layout()

# 9. Saving the plot
plt.savefig("mesh_comvergence.png", dpi=300)
plt.show()

# --- Plotting L2 error ---
plt.figure(figsize=(10, 6))

# 10. Plotting L2 error per file name
plt.plot(
    ["nx"],
    ["L2 error"],
    marker="s",
    linewidth=2,
)

# 11. Formatting in log-log scale (standard for convergence rate analysis)
plt.xscale("log")
plt.yscale("log")
plt.title("Mesh convergence analysis — L2 Error vs Mesh Refinement", fontsize=13)
plt.xlabel("Number of longitudinal elements (nx)", fontsize=11)
plt.ylabel("L2 Error", fontsize=11)
plt.grid(True, which="both", linestyle=":", alpha=0.7)
plt.legend(loc="best", frameon=True)
plt.tight_layout()

# 12. Saving the second plot and displaying both figures
plt.savefig("L2_error_convergence.png", dpi=300)
plt.show()
