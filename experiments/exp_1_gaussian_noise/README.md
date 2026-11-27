Expérience 1 :

Influence de données d'entraînement corrompues sur le backbone.

Idée:
Prendre les corruptions de https://arxiv.org/pdf/1903.12261
(Benchmarking Neural Network Robustness to Common Corruptions and Perturbations)

Entraîner un LeJEPA from scratch sur le dataset retenu par le pilote (cf PROTOCOLE.md), avec une fraction p des images d'entraînement corrompues.
On corrompt le dataset de base une fois pour toutes, sans toucher à la pipeline d'entraînement (augmentations, loss).
C'est le même cadre que pour les attaques plus tard : l'attaquant modifie les données, pas l'entraînement.

Comparer ensuite (même backbone, mêmes seeds etc) les modèles pour différentes valeurs de p.


Hypothèse:

La loss de LeJEPA rend le modèle invariant à ce qui change entre les vues d'une même image.
Une corruption figée dans le dataset est présente dans toutes les vues de l'image, donc rien ne pousse le modèle à l'ignorer : il risque de l'encoder comme du signal.
C'est l'inverse du résultat de https://arxiv.org/pdf/2505.12477, où le bruit tiré à la volée dans l'augmentation améliore les représentations.

On s'attend donc à une dégradation quand p augmente.
À regarder : est-ce que ça dépend de la famille de corruption ? (bruit haute fréquence vs brouillard / contraste, cf Yin et al. 2019, https://arxiv.org/abs/1906.08988)


Corruption du dataset:

- corruptions utilisées : les 15 du benchmark de Hendrycks (bruit, flou, météo, numérique)
- corruptions non vues : les 4 corruptions de validation du papier (speckle noise, gaussian blur, spatter, saturate), jamais utilisées à l'entraînement
- on tire une fraction p des images du train (seed fixée). Pour chacune : une corruption au hasard parmi les 15 et une sévérité au hasard entre 1 et 5
- le tirage est fait une seule fois et sauvegardé (quelles images, quelle corruption, quelle sévérité)
- les benchmarks corrompus (CIFAR-10-C, ImageNet-C...) ne couvrent que le test, donc on génère nous-mêmes le train corrompu avec le code du papier (make_cifar_c.py, make_tinyimagenet_c.py...)


Conditions:

- p dans {0, 0.1, 0.25, 0.5, 1}
- p = 0 == la baseline (LeJEPA propre)
- mm backbone, mm hyperparamètres, mm augmentations pour tout le monde (cf PROTOCOLE.md)
- 3 seeds par valeur de p, donc 15 runs

Contrôle si on a le temps : mêmes corruptions, mais tirées à la volée dans l'augmentation au lieu d'être figées dans le dataset. Ça teste directement l'hypothèse.


Évaluation:

Tout passe par le protocole commun (PROTOCOLE.md). Ce qu'on regarde en priorité ici :

- accuracy propre, mCE et Relative mCE en fonction de p, en séparant corruptions vues et non vues
- structure de l'espace latent en fonction de p : statistique SIGReg, rang effectif, invariance entre f(x) et f(corruption(x))
- t-SNE (cf Figure 2 de https://arxiv.org/pdf/2505.12477) : p = 0 vs p = 1, sur le test propre et sur le test corrompu (fog sévérité 5 comme dans le papier)


Résultats attendus:

- courbes des métriques en fonction de p
- figure t-SNE 2x2 (p = 0 / p = 1, test propre / test corrompu)
- réponse à : à partir de quel p le backbone se dégrade, et sur quelles corruptions


Questions ouvertes:

- tirage au hasard parmi les 15 corruptions, ou une seule corruption par run ? (une seule c'est plus lisible, mais beaucoup plus de runs)
- est-ce que les valeurs de p sont les bonnes ? à revoir après les premiers runs, on rajoutera peut-être des petites valeurs (0.01, 0.05) pour l'adversarial
