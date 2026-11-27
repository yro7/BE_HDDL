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


# N-JEPA : bruit "diffusion" sur les positional embeddings (à garder comme variante de StoP, pas comme idée à part)

Papier : Qiu, Zhu, Chen (2025), *Improving Joint Embedding Predictive Architecture with Diffusion Noise*, [arXiv:2507.15216](https://arxiv.org/abs/2507.15216). Preprint, pas publié. Pas de code ("Codes will be released soon").

## Ce que fait le papier

- Base : I-JEPA, ViT-B/16, ImageNet-1k, 100 et 600 epochs.
- Comme StoP, le bruit n'est **pas** sur l'image. Il est ajouté aux positional embeddings des blocs masqués, dans le prédicteur.
- Deux prédicteurs : un sans bruit, un avec bruit. Loss totale : $\mathcal{L} = \mathcal{L}_{C\text{-}T} + \lambda_1 \mathcal{L}_{N\text{-}T} + \lambda_2 \mathcal{L}_{C\text{-}N}$, où $\mathcal{L}_{C\text{-}N}$ force la prédiction bruitée à ressembler à la prédiction propre.
- Le niveau de bruit $\sigma$ est tiré comme dans EDM (log-normal), avec un "multi-level noise schedule".
- Résultats : +1.5 pt en linear probe par rapport à leur reproduction d'I-JEPA, +2.5 à +4.3 pts en low-shot (1 % / 10 % des labels).

## Avis critique

- **Il n'y a pas de diffusion.** Pas de processus inverse, pas de score matching, pas de génération. Concrètement c'est du bruit gaussien isotrope sur les positions des tokens masqués, plus une loss de cohérence propre/bruité. Le mot "diffusion" est surtout de l'emballage.
- **C'est très proche de StoP** (Bar et al., cf. idée précédente), dont la v1 s'appelait FlexPredict. Ils le citent mais ne s'y comparent pas. Les deux vraies différences : $\sigma$ tiré aléatoirement au lieu d'une covariance apprise, et la loss de cohérence $\mathcal{L}_{C\text{-}N}$.
- **Les résultats sont fragiles** : un seul run par configuration, aucune seed, aucune barre d'erreur. Beaucoup d'écarts sont de 0.2 à 0.4 pt, ce qui est probablement du bruit de seed. Les poids $\lambda$ et le schedule ont été choisis directement sur le linear probe qu'ils rapportent. Ils mentionnent un bug de scheduler corrigé (`ipe_scale = 1.25`) sans dire si la baseline I-JEPA a eu la même correction.
- **"Robustness" n'est pas testée.** L'abstract dit que le schedule "enhance[s] the robustness", mais il n'y a ni ImageNet-C, ni images bruitées au test, ni attaque adversariale.
- Le papier est négligé : I-JEPA attribué à "Yann LeCun et al." au lieu d'Assran, texte de template LaTeX resté dans le bloc auteurs, plusieurs coquilles.

## Ce qu'on peut en garder

On ne le prend pas comme référence principale, mais il apporte une composante intéressante pour nous : la **loss de cohérence** $\mathcal{L}_{C\text{-}N}$. C'est une contrainte d'invariance explicite (prédiction propre ≈ prédiction bruitée), et l'invariance est justement ce qu'on soupçonne de rendre un modèle robuste.

Ajout au protocole StoP :
1. I-JEPA (baseline)
2. I-JEPA + bruit isotrope sur les positions des cibles, $\sigma$ fixe
3. I-JEPA + StoP ($\Sigma$ apprise)
4. I-JEPA + bruit sur les positions + loss de cohérence (version N-JEPA)

Même budget, plusieurs seeds, évaluation sur CIFAR-10-C en robustesse effective. Ça permet de séparer trois facteurs : "il y a du bruit", "la covariance est apprise", "on impose l'invariance". C'est plus intéressant que de reproduire N-JEPA tel quel, et ça répond mieux à *what makes...*.


# PhiJEPA : prédire une vue corrompue puis la "débruiter" vers la vue propre (le plus proche de notre sujet)

Papier : Yamada, Tsai (2026), *PhiJEPA: Denoising Latent Predictions for Visual Representation Learning*, [arXiv:2611.27516](https://arxiv.org/abs/2611.27516). Preprint du 20/11/2026, pas de code publié.

## Idée clé

Contrairement à StoP et N-JEPA, ici la corruption est **sur les pixels** : color jitter, grayscale, flou gaussien, solarisation, bruit gaussien additif.

La prédiction se fait en deux étages (analogie hippocampe CA3 → CA1, reprise de PhiNet) :
1. L'étudiant voit le contexte d'une vue corrompue $\tilde x_1 = a_1(x)$. Un bloc Transformer $h$ prédit les tokens cibles du teacher EMA calculés sur une **autre** vue corrompue indépendamment, $\tilde x_2 = a_2(x)$.
2. Un MLP token par token $g$ (sans attention) transforme cette prédiction pour retrouver les tokens du teacher sur l'image **propre** $x$.

$$\mathcal{L} = \frac{1}{|T|}\sum_t \Big[ d\big(\tilde z_t, \mathrm{sg}(\tilde y_t)\big) + \lambda\, d\big(g(\tilde z_t), \mathrm{sg}(y_t)\big) \Big], \quad d(u,v) = 2 - 2\cos(u,v), \ \lambda = 0.5$$

Le "débruitage" est donc l'étage $g$ : corrompu → propre dans l'espace latent. Il n'y a pas de bruit ajouté dans les latents et pas de diffusion.

Leur explication : comme les deux vues sont corrompues indépendamment, le modèle ne peut prédire que ce qu'elles ont en commun, c'est-à-dire le contenu et pas la corruption. L'étage $g$ ajoute ensuite une référence propre qui façonne aussi la représentation.

## Résultats

- ViT-B/16, ImageNet-1k, 400 epochs, comparé à leur "Simple I-JEPA" au même nombre d'epochs.
- Segmentation VOC : 66.2 → 69.3 mIoU. ADE20K : 29.2 → 30.7. Linear probe ImageNet : pareil (72.1 vs 72.0).
- **Robustesse** : accuracy moyenne sur bruit gaussien, flou, JPEG, contraste et luminosité (sévérité 3) de 54.3 % à 64.9 %. Par contre, sur les occultations, ils baissent : 50.9 % → 47.1 %.
- Ablation (une seed) : corrompre l'étudiant seul ne sert à rien (65.4 / 65.9 en VOC). C'est la combinaison cible corrompue indépendante + étage $g$ qui apporte le gain (69.2).

## Avis critique

- **C'est le papier le plus en lien avec notre question**, parce qu'il touche vraiment aux images corrompues et qu'il mesure (un peu) la robustesse.
- **Gros problème de contrôle** : les corruptions d'entraînement (bruit gaussien, flou) sont presque les mêmes que celles du test. Le gain 54 % → 65 % peut venir juste du fait d'avoir vu ces corruptions pendant l'entraînement. Il manque la baseline évidente : Simple I-JEPA entraîné avec **les mêmes augmentations** mais sans l'étage $g$. L'ablation (b) s'en rapproche, mais elle n'est évaluée qu'en segmentation propre, pas en robustesse.
- Une seule run de pré-entraînement par configuration. Écarts de 1 à 3 pts sans barre d'erreur, alors que leur propre sweep de $p$ / $\lambda$ varie déjà de 68.0 à 69.9 en VOC.
- Hyperparamètres choisis sur les évaluations rapportées. PhiJEPA coûte environ 56 % de FLOPs en plus que Simple I-JEPA (deux passes du teacher).
- Pas d'ImageNet-C : leurs propres corruptions, une seule sévérité. Pas d'adversarial.
- L'abstract met en avant le meilleur cas (planning PushT 33 % → 65 % avec un flou dans la plage vue à l'entraînement). Avec un flou plus fort, iBOT fait mieux.
- Les auteurs sont honnêtes sur les limites ("do not establish superiority under matched compute", pas de robustesse générale aux occultations).

## Ce qu'on peut en tirer pour le BE

Ça s'emboîte directement avec l'**expérience 1** (bruit gaussien pendant l'entraînement du backbone). PhiJEPA permet de découper la question "qu'est-ce qui rend robuste ?" en facteurs, et de tester le contrôle qu'ils n'ont pas fait :

1. I-JEPA, images propres (baseline)
2. I-JEPA, étudiant **et** teacher sur la même image bruitée (= notre exp 1 "dataset bruité")
3. I-JEPA, étudiant bruité, cible propre (ablation b)
4. I-JEPA, étudiant bruité, cible bruitée indépendamment (ablation c)
5. PhiJEPA complet (cible bruitée indépendante + étage $g$ vers la cible propre)

Évaluation sur CIFAR-10-C, en séparant les corruptions **vues** à l'entraînement (bruit gaussien) et **non vues** (brouillard, contraste, pixelisation, JPEG...), avec plusieurs seeds et en robustesse effective.

Question falsifiable : est-ce que l'étage de débruitage $g$ apporte de la robustesse **au-delà** de la simple augmentation par le bruit (2 vs 5), et est-ce que ça se généralise aux corruptions non vues ? Si le gain disparaît sur les corruptions non vues, alors ce qui rend robuste, c'est d'avoir vu la corruption, pas l'architecture.

Lien avec les idées précédentes : StoP / N-JEPA bruitent les **positions**, PhiJEPA bruite les **pixels**. Comparer les deux familles sur CIFAR-10-C permettrait de dire quel type de bruit à l'entraînement compte vraiment pour la robustesse aux corruptions.
