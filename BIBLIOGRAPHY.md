# Bibliographie — « What makes a neural network robust to corrupted images? »

Les IDs arXiv ci-dessous ont été vérifiés via le MCP arXiv (titre + auteurs). Les références hors arXiv sont signalées.

---

## 0. Cadre proposé : définir « corrupted » et « robust »

### 0.1 Notations

- Classifieur $f : \mathcal{X} \to \mathcal{Y}$, entraîné sur une distribution « propre » $\mathcal{D}$ sur $\mathcal{X}\times\mathcal{Y}$.
- **Corruption** : une transformation (éventuellement aléatoire) $c_{t,s} : \mathcal{X} \to \mathcal{X}$, indexée par un **type** $t \in \mathcal{T}$ (bruit gaussien, flou, JPEG, brouillard…) et une **sévérité** $s$.
- **Hypothèse de préservation sémantique** : la classe « vraie » (celle d'un oracle humain) reste la même, $y(c_{t,s}(x)) = y(x)$. C'est cette hypothèse qui distingue une corruption d'un changement de contenu. Elle est fausse aux sévérités extrêmes : il faut la justifier, par exemple avec une baseline humaine (Geirhos 2018).
- Distribution corrompue $\mathcal{D}_{t,s}$ = image de $\mathcal{D}$ par $c_{t,s}$. Il s'agit d'un cas particulier de **covariate shift** : $p(x)$ change, l'étiquette est conservée.

### 0.2 Les axes qui définissent une « corruption »

| Axe | Pôles | Références clés |
|---|---|---|
| Pire cas vs cas moyen | adversarial ($\max_{\|\delta\|\le\varepsilon}$) vs aléatoire ($\mathbb{E}_{c}$) | Fawzi 2016, Ford 2019, Gilmer 2018 |
| Synthétique vs naturel | ImageNet-C vs ImageNet-V2 / photos réelles | Hendrycks 2019, Recht 2019, Taori 2020 |
| Vue vs inconnue à l'entraînement | corruption présente dans l'augmentation ou non | Mintun 2021, Kireev 2021 |
| Famille | bruit / flou / météo / numérique / géométrique | Hendrycks 2019, Azulay 2018 |
| Contenu fréquentiel | hautes fréquences (bruit) vs basses fréquences (brouillard, contraste) | Yin 2019 |

À écarter explicitement : la corruption **des étiquettes** (label noise) et celle **des données d'entraînement** (contamination à la Huber, poisoning). Le sujet porte sur des **entrées corrompues au moment du test**.

### 0.3 Les définitions de « robuste » (de la plus locale à la plus globale)

1. **Stabilité locale ou pire cas** : $f(x+\delta) = f(x)$ pour tout $\|\delta\|\le\varepsilon$. On la mesure par un rayon certifié ou une constante de Lipschitz (Hein 2017, Madry 2017, Cohen 2019).
2. **Performance moyenne sous corruption** : $\mathrm{Acc}(f, \mathcal{D}_{t,s})$, agrégée sur les types et les sévérités. Les métriques sont le **mCE** et le **relative mCE** (Hendrycks 2019).
3. **Stabilité des prédictions** : probabilité de changement de prédiction (flip) sous une perturbation progressive, le **mFP** d'ImageNet-P (Hendrycks 2019).
4. **Robustesse effective vs relative** (Taori 2020, Miller 2021) : l'accuracy OOD est fortement corrélée à l'accuracy ID (*accuracy on the line*). Un facteur ne « rend robuste » que s'il **dépasse cette tendance**. Sinon, il améliore seulement le modèle en général. C'est **le critère central pour répondre à « what makes… »**.
5. **Fiabilité sous corruption** : calibration et incertitude sous shift (Ovadia 2019). Un modèle robuste doit aussi savoir quand il se trompe.

Pour relier tout ça à la robustesse statistique (lien Wikipedia) : en statistique, un estimateur robuste résiste à une fraction $\varepsilon$ de données contaminées (point de rupture, fonction d'influence). L'analogue pour nous est un classifieur dont la sortie varie peu quand l'entrée est contaminée. Xu & Mannor (2010) formalisent le lien entre robustesse et généralisation.

### 0.4 Les leviers possibles (variables explicatives de « what makes »)

- **Données** : augmentations (bruit gaussien, AugMix), échelle et diversité du pré-entraînement (Fang 2022).
- **Architecture** : CNN vs ViT (Bai 2021), anti-aliasing (Zhang 2019), biais inductifs forme/texture (Geirhos 2019).
- **Objectif d'entraînement** : entraînement adversarial (Madry 2017, Kireev 2021), entraînement bruité (Rusak 2020).
- **Test-time** : ré-estimation des statistiques de BatchNorm (Schneider 2020).

Un protocole expérimental cohérent avec ce cadre : on fait varier un levier à la fois, on évalue sur CIFAR-10-C / ImageNet-C (et sur des corruptions *hors* benchmark, à la Mintun 2021), puis on rapporte la **robustesse effective** plutôt que l'accuracy brute.

---

## 1. Définir la robustesse (cadres conceptuels et surveys)

- **Drenkow, Sani, Shpitser, Unberath (2021)**. *A Systematic Review of Robustness in Deep Learning for Computer Vision: Mind the gap?* — [arXiv:2112.00639](https://arxiv.org/abs/2112.00639)
  → Point de départ idéal : montre que « robustesse » est utilisé de façon ambiguë et propose une taxonomie. **À lire en premier.**
- **Wang, Veldhuis, Brune, Strisciuglio (2023)**. *A Survey on the Robustness of Computer Vision Models against Common Corruptions* — [arXiv:2305.06024](https://arxiv.org/abs/2305.06024)
  → Survey centré exactement sur notre sujet (corruptions communes) : méthodes, benchmarks, résultats.
- **Gilmer, Adams, Goodfellow, Andersen, Dahl (2018)**. *Motivating the Rules of the Game for Adversarial Example Research* — [arXiv:1807.06732](https://arxiv.org/abs/1807.06732)
  → Critique le modèle de menace « petite norme $\ell_p$ » et plaide pour des perturbations réalistes. Utile pour justifier le choix de « corrupted » plutôt que « adversarial ».
- **Xu & Mannor (2010)**. *Robustness and Generalization* — [arXiv:1005.2243](https://arxiv.org/abs/1005.2243)
  → Définition formelle de la robustesse d'un algorithme et lien avec la généralisation (cadre théorique).
- **Freiesleben & Grote (2023)**. *Beyond generalization: a theory of robustness in machine learning*. *Synthese*. *(hors arXiv)*
  → Cadre philosophique et conceptuel : robustesse = *de quoi* (cible), *face à quoi* (modificateur), *dans quelle mesure*. Très utile pour structurer l'introduction.
- **Huber (1964)**. *Robust Estimation of a Location Parameter*. *Ann. Math. Statist.* ; **Hampel et al. (1986)**. *Robust Statistics: The Approach Based on Influence Functions*. *(hors arXiv)*
  → Origine statistique de la notion (ε-contamination, point de rupture).
- **Quiñonero-Candela et al. (2009)**. *Dataset Shift in Machine Learning*, MIT Press ; **Moreno-Torres et al. (2012)**. *A unifying view on dataset shift in classification*. *Pattern Recognition*. *(hors arXiv)*
  → Vocabulaire de base : covariate shift, prior shift, concept shift. Les corruptions relèvent du covariate shift.

## 2. Définir et mesurer la corruption (benchmarks)

- **Hendrycks & Dietterich (2019)**. *Benchmarking Neural Network Robustness to Common Corruptions and Perturbations* — [arXiv:1903.12261](https://arxiv.org/abs/1903.12261)
  → **Référence centrale.** ImageNet-C / CIFAR-10-C : 15 corruptions × 5 sévérités, 4 familles. Métriques mCE, relative mCE, mFP. Il faudra très probablement s'appuyer dessus.
- **Dodge & Karam (2016)**. *Understanding How Image Quality Affects Deep Neural Networks* — [arXiv:1604.04004](https://arxiv.org/abs/1604.04004)
  → Première étude systématique : flou, bruit, contraste, JPEG.
- **Geirhos et al. (2018)**. *Generalisation in humans and deep neural networks* — [arXiv:1808.08750](https://arxiv.org/abs/1808.08750)
  → Compare humains et CNN sous 12 dégradations. Montre qu'un réseau entraîné sur une corruption ne généralise pas aux autres. Fournit la baseline humaine (hypothèse de préservation sémantique).
- **Mintun, Kirillov, Xie (2021)**. *On Interaction Between Augmentations and Corruptions in Natural Corruption Robustness* — [arXiv:2102.11273](https://arxiv.org/abs/2102.11273)
  → ImageNet-C̄ : les gains sur ImageNet-C viennent en partie de la *similarité* entre augmentations et corruptions de test. **Indispensable pour ne pas sur-interpréter nos résultats.**
- **Hendrycks et al. (2020)**. *The Many Faces of Robustness: A Critical Analysis of Out-of-Distribution Generalization* — [arXiv:2006.16241](https://arxiv.org/abs/2006.16241)
  → ImageNet-R, DeepAugment. Aucune méthode n'améliore la robustesse sur tous les types de shift : la robustesse est multidimensionnelle.

## 3. Robustesse effective vs accuracy (critère de « what makes »)

- **Recht, Roelofs, Schmidt, Shankar (2019)**. *Do ImageNet Classifiers Generalize to ImageNet?* — [arXiv:1902.10811](https://arxiv.org/abs/1902.10811)
  → Même sur un shift minime, l'accuracy chute de 11 à 14 %, mais de façon linéaire avec l'accuracy d'origine.
- **Taori et al. (2020)**. *Measuring Robustness to Natural Distribution Shifts in Image Classification* — [arXiv:2007.00644](https://arxiv.org/abs/2007.00644)
  → Introduit la **effective robustness** (gain au-delà de la tendance ID→OOD) et la **relative robustness**. Montre que la robustesse aux corruptions synthétiques ne transfère pas aux shifts naturels.
- **Miller et al. (2021)**. *Accuracy on the Line: On the Strong Correlation Between Out-of-Distribution and In-Distribution Generalization* — [arXiv:2107.04649](https://arxiv.org/abs/2107.04649)
  → Corrélation ID/OOD très forte, mais **plus faible sur certaines corruptions de CIFAR-10-C**. C'est précisément là que la question « what makes » devient intéressante.

## 4. Lien adversarial ↔ corruptions aléatoires

- **Fawzi, Moosavi-Dezfooli, Frossard (2016)**. *Robustness of classifiers: from adversarial to random noise* — [arXiv:1608.08967](https://arxiv.org/abs/1608.08967)
  → Théorie : la robustesse au bruit aléatoire est d'un facteur $\sqrt{d}$ plus grande que la robustesse adversariale (dépend de la courbure de la frontière de décision).
- **Ford, Gilmer, Carlini, Cubuk (2019)**. *Adversarial Examples Are a Natural Consequence of Test Error in Noise* — [arXiv:1901.10513](https://arxiv.org/abs/1901.10513)
  → Robustesse adversariale et robustesse au bruit sont les deux faces d'un même phénomène géométrique.
- **Laugros, Caplier, Ospici (2019)**. *Are Adversarial Robustness and Common Perturbation Robustness Independent Attributes?* — [arXiv:1909.02436](https://arxiv.org/abs/1909.02436)
  → Réponse empirique : largement indépendantes. Contrepoint utile à Ford 2019.
- **Madry et al. (2017)**. *Towards Deep Learning Models Resistant to Adversarial Attacks* — [arXiv:1706.06083](https://arxiv.org/abs/1706.06083)
  → Formulation min-max de la robustesse pire cas (PGD).
- **Hein & Andriushchenko (2017)**. *Formal Guarantees on the Robustness of a Classifier against Adversarial Manipulation* — [arXiv:1705.08475](https://arxiv.org/abs/1705.08475)
  → Bornes inférieures sur le rayon de robustesse, liées au comportement Lipschitz local.
- **Cohen, Rosenfeld, Kolter (2019)**. *Certified Adversarial Robustness via Randomized Smoothing* — [arXiv:1902.02918](https://arxiv.org/abs/1902.02918)
  → Un classifieur bon sous bruit gaussien devient certifiablement robuste en $\ell_2$. Pont formel entre les deux notions.
- **Tsipras et al. (2018)**. *Robustness May Be at Odds with Accuracy* — [arXiv:1805.12152](https://arxiv.org/abs/1805.12152)
  → Compromis robustesse/accuracy. Les modèles robustes apprennent des features plus « humaines ».

## 5. Qu'est-ce qui rend robuste ? (leviers testables)

**Données et augmentation**
- **Rusak et al. (2020)**. *A simple way to make neural networks robust against diverse image corruptions* — [arXiv:2001.06057](https://arxiv.org/abs/2001.06057)
  → L'augmentation par bruit gaussien bien calibrée est une baseline très forte sur ImageNet-C. **Facile à reproduire.**
- **Hendrycks et al. (2019)**. *AugMix: A Simple Data Processing Method to Improve Robustness and Uncertainty* — [arXiv:1912.02781](https://arxiv.org/abs/1912.02781)
  → Méthode d'augmentation de référence sur CIFAR-10-C / ImageNet-C, avec perte de consistance (Jensen-Shannon).
- **Kireev, Andriushchenko, Flammarion (2021)**. *On the effectiveness of adversarial training against common corruptions* — [arXiv:2103.02325](https://arxiv.org/abs/2103.02325)
  → L'entraînement adversarial $\ell_p$ avec un petit rayon aide sur les corruptions. Identifie le **σ-overfitting** : l'augmentation gaussienne sur-apprend une variance donnée.
- **Fang et al. (2022)**. *Data Determines Distributional Robustness in Contrastive Language Image Pre-training (CLIP)* — [arXiv:2205.01397](https://arxiv.org/abs/2205.01397)
  → La robustesse de CLIP vient de la **diversité des données**, pas du langage ni de l'objectif contrastif.

**Biais inductifs et représentations**
- **Geirhos et al. (2019)**. *ImageNet-trained CNNs are biased towards texture; increasing shape bias improves accuracy and robustness* — [arXiv:1811.12231](https://arxiv.org/abs/1811.12231)
  → Biais texture vs forme. Stylized-ImageNet augmente le biais de forme et la robustesse aux corruptions.
- **Geirhos et al. (2020)**. *Shortcut Learning in Deep Neural Networks* — [arXiv:2004.07780](https://arxiv.org/abs/2004.07780)
  → Cadre explicatif général : les réseaux apprennent des « raccourcis » qui cassent hors distribution.
- **Yin et al. (2019)**. *A Fourier Perspective on Model Robustness in Computer Vision* — [arXiv:1906.08988](https://arxiv.org/abs/1906.08988)
  → Explique *pourquoi* une augmentation aide sur certaines corruptions et nuit sur d'autres : le réseau devient invariant aux hautes fréquences et sensible aux basses. **Grille d'analyse très exploitable.**

**Architecture**
- **Zhang (2019)**. *Making Convolutional Networks Shift-Invariant Again* — [arXiv:1904.11486](https://arxiv.org/abs/1904.11486)
  → L'anti-aliasing (low-pass avant downsampling) améliore la stabilité et la robustesse aux corruptions.
- **Azulay & Weiss (2018)**. *Why do deep convolutional networks generalize so poorly to small image transformations?* — [arXiv:1805.12177](https://arxiv.org/abs/1805.12177)
  → La convolution n'apporte pas l'invariance attendue (le théorème d'échantillonnage est ignoré).
- **Bai, Mei, Yuille, Xie (2021)**. *Are Transformers More Robust Than CNNs?* — [arXiv:2111.05464](https://arxiv.org/abs/2111.05464)
  → À protocole d'entraînement égal, l'écart CNN/ViT se réduit fortement. **Leçon méthodologique : contrôler les facteurs confondants.**

**Adaptation au test**
- **Schneider et al. (2020)**. *Improving robustness against common corruptions by covariate shift adaptation* — [arXiv:2006.16971](https://arxiv.org/abs/2006.16971)
  → Re-estimer les statistiques de BatchNorm sur les données corrompues donne de gros gains sur ImageNet-C. Expérience très simple à reproduire.

## 6. Au-delà de l'accuracy

- **Ovadia et al. (2019)**. *Can You Trust Your Model's Uncertainty? Evaluating Predictive Uncertainty Under Dataset Shift* — [arXiv:1906.02530](https://arxiv.org/abs/1906.02530)
  → La calibration se dégrade sous shift (y compris sur des corruptions de type ImageNet-C). Les ensembles s'en sortent le mieux.

---

## Ordre de lecture suggéré

1. Drenkow 2021 (taxonomie) → Hendrycks & Dietterich 2019 (définition opérationnelle de « corrupted »)
2. Taori 2020 + Miller 2021 (définition rigoureuse de « robust » : robustesse effective)
3. Yin 2019 + Geirhos 2019 (mécanismes explicatifs)
4. Rusak 2020, Schneider 2020, Mintun 2021 (leviers reproductibles + piège méthodologique)
5. Survey Wang 2023 pour compléter

---

Notion de « robustesse » (statistique) :
https://fr.wikipedia.org/wiki/Robustesse_(statistiques)

Autre:

Steinhardt, Koh, Liang (2017), Certified Defenses for Data Poisoning Attacks, arXiv:1706.03691. Donne des bornes sur la perte dans le pire cas quand on retire les outliers avant d'entraîner.
Tran, Li, Madry (2018), Spectral Signatures in Backdoor Attacks, arXiv:1811.00636. Les exemples empoisonnés laissent une signature dans les représentations internes, qu'on détecte avec des outils de statistique robuste.
Levine & Feizi (2020), Deep Partition Aggregation: Provable Defense against General Poisoning Attacks, arXiv:2006.14768. Certification par ensemble de modèles entraînés sur des partitions disjointes. C'est l'analogue du randomized smoothing pour l'empoisonnement.
Schwarzschild et al. (2020), Just How Toxic is Data Poisoning? A Unified Benchmark for Backdoor and Data Poisoning Attacks, arXiv:2006.12557. Un benchmark unifié, qui montre que beaucoup d'attaques publiées s'effondrent dans des conditions réalistes.
