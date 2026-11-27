IDEAS.md

# I-JEPA : Immunité sur label flipping
 L'entraînement initial (pré-entraînement) d'un I-JEPA strictement auto-supervisé (sans étiquettes humaines).
 Conséquence : Les attaques classiques par inversion d'étiquettes (label flipping) sont totalement inopérantes lors du pré-entraînement. 
 
 ⟶ L'attaquant doit agir directement sur la structure physique ou sémantique des données brutes (images, vidéos).   

# Bruit sur les positional embeddings (StoP) : est-ce que ça rend le JEPA robuste aux images corrompues ?

Papier : Bar, Bordes, Shocher, Assran, Vincent, Ballas, Darrell, Globerson, LeCun (2023), *Stochastic positional embeddings improve masked image modeling*, [arXiv:2308.00566](https://arxiv.org/abs/2308.00566). Code : https://github.com/amirbar/StoP

## Ce que fait le papier

- Base : I-JEPA. Le bruit n'est **pas** mis sur l'image, ni dans l'encodeur. Il est mis dans le **prédicteur**, sur les positional embeddings des tokens **masqués** (les cibles à prédire).
- Formulation : $\hat\psi_j = \psi_j + A n_j$ avec $n_j \sim \mathcal{N}(0, \sigma I)$, donc $\hat\psi_j \sim \mathcal{N}(\psi_j, \sigma A A^\top)$. La covariance est apprise via $A$.
- Problème : le modèle peut apprendre $A = 0$ et supprimer le bruit. Solution : $A$ est partagée avec la projection des tokens de contexte. Si $A \to 0$, le contexte disparaît aussi, donc le modèle ne peut pas tricher.
- Résultats (ImageNet-1k, linear probing) : +1.7 pts en ViT-B, +3.2 pts avec 1% des labels. Le bruit sur les cibles seules marche mieux que sur le contexte.
- Leur explication : la position exacte d'une partie d'objet est incertaine. Sans bruit, le modèle "overfit" sur la position. Avec bruit, il apprend des features plus sémantiques et moins liées à la localisation. Le prédicteur optimal devient une convolution gaussienne de la prédiction propre (Prop. 3.2), donc une forme de lissage.

## Mon idée

Le papier ne teste **pas** la robustesse aux corruptions d'images (pas d'ImageNet-C). Pour eux, "robuste" veut dire robuste à l'incertitude sur la position. On peut donc faire du reverse engineering : prendre leur mécanisme et se demander s'il explique une partie de la réponse à *what makes a neural network robust to corrupted images?*

Hypothèse : si StoP pousse l'encodeur à ne plus dépendre de détails locaux précis, alors ses représentations devraient moins bouger quand l'image est abîmée localement (bruit gaussien, shot noise, flou, pixelisation, JPEG).

## Expérience proposée

1. Pré-entraîner deux I-JEPA (petit ViT, CIFAR-10), même seed, mêmes hyperparamètres : un sans bruit, un avec StoP. Plusieurs seeds.
2. Linear probe sur CIFAR-10 propre, puis évaluation sur CIFAR-10-C (types × sévérités).
3. Comparer en **robustesse effective** (Taori 2020) et pas seulement en accuracy brute : si StoP améliore juste le modèle en général, ce n'est pas un gain de robustesse.
4. Faire varier $\sigma$ (0, 0.1, 0.25, 0.5) pour voir si la robustesse suit le niveau de bruit.
5. Ablations : $\Sigma$ apprise vs $\Sigma = \sigma I$ fixe, bruit sur cibles vs contexte.
6. Analyse : distance entre représentation propre et corrompue $\|f(x) - f(c(x))\|$ par type de corruption, t-SNE, et lien avec les fréquences (le lissage du prédicteur est un filtre passe-bas, à rapprocher de Yin 2019).

## Points d'attention

- Le bruit est dans le prédicteur, qui est jeté après le pré-entraînement. L'effet sur la robustesse est donc indirect, via ce que l'encodeur apprend. C'est justement ce qui est intéressant à expliquer.
- Le papier est sur ImageNet avec de gros ViT. Sur CIFAR avec un petit ViT, le gain peut être faible ou nul.
- Un résultat négatif reste utile : ça montrerait que robustesse à la position et robustesse aux corruptions sont deux choses différentes.
- On peut s'attendre à un effet différent selon la famille de corruption (bruit haute fréquence vs brouillard / contraste basse fréquence).
