IDEAS.md

# LeJEPA : Immunité sur label flipping
 L'entraînement initial (pré-entraînement) d'un LeJEPA strictement auto-supervisé (sans étiquettes humaines).
 Conséquence : Les attaques classiques par inversion d'étiquettes (label flipping) sont totalement inopérantes lors du pré-entraînement. 
 
 ⟶ L'attaquant doit agir directement sur la structure physique ou sémantique des données brutes (images, vidéos).   

# StoP : bruit sur les positions
[arXiv:2308.00566](https://arxiv.org/abs/2308.00566) · code : https://github.com/amirbar/StoP

- **Idée** : dans LeJEPA, bruit gaussien sur les positional embeddings des tokens masqués (dans le prédicteur, pas sur l'image).
- **Résultat** : +1.7 pt en linear probe. Pas de test sur des images corrompues.
- **Pour nous** : tester si ça rend aussi robuste aux corruptions (CIFAR-10-C).

# N-JEPA : bruit "diffusion" sur les positions
[arXiv:2507.15216](https://arxiv.org/abs/2507.15216)

- **Idée** : presque la même chose que StoP, avec en plus une loss de cohérence entre prédiction propre et prédiction bruitée.
- **Limites** : pas de vraie diffusion, une seule run par config, robustesse annoncée mais pas testée.
- **Pour nous** : on garde seulement la loss de cohérence, comme variante de StoP.

# PhiJEPA : débruitage dans l'espace latent
[arXiv:2611.27516](https://arxiv.org/abs/2611.27516)

- **Idée** : bruit sur les pixels. On prédit une autre vue bruitée, puis un MLP ramène la prédiction vers la vue propre.
- **Résultat** : 54 % → 65 % sous corruption.
- **Limite** : le test utilise les mêmes corruptions que l'entraînement, et il n'y a pas de baseline "même bruit sans MLP".
- **Pour nous** : faire ce contrôle dans l'exp 1, en séparant les corruptions vues et non vues.

# Benchmark : CIFAR-10-C
[arXiv:1903.12261](https://arxiv.org/abs/1903.12261) (version publiée de 1807.01697) · données : https://zenodo.org/record/2535967

- 15 corruptions × 5 sévérités, plus 4 corruptions de validation.
- Métriques : mCE et Relative mCE, normalisés par notre baseline LeJEPA propre.
- Le papier conclut que la robustesse vient surtout d'une meilleure accuracy, donc il faut regarder le Relative mCE.

# Plan d'expérience
Même ViT, plusieurs seeds, évaluation sur CIFAR-10-C :
1. LeJEPA propre (baseline)
2. LeJEPA bruité (exp 1)
3. PhiJEPA
4. StoP (avec ou sans loss de cohérence)
