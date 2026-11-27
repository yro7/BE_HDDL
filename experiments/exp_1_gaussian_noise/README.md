Expérience 1 : 

Influence du bruit sur l'entraînement des backbone.

Idée:
Prendre l'exemple de https://arxiv.org/pdf/1903.12261
(Benchmarking Neural Network Robustness to Common Corruptions and Perturbations)

Entraîner un JEPA from scratch avec un dataset donné sain.
puis comparer (même seed etc) Sain VS dataset bruité.

Résultats attendus: comparaison des performances finales des 2 JEPA + visualisation des représentations internes des 2 JEPA (cf https://arxiv.org/pdf/2505.12477) "(Figure 2: Injecting corruption-aligned noise into data augmentation improves SSL representa-
tion quality on corrupted CIFAR-10. Thus aligning augmentations with the irrelevant
components in the data is crucial in SSL. t-SNE [58] visualizations of (left to right):
(1) Supervised features (penultimate layer), clean data. (2) Supervised features (penultimate
layer), fog-corrupted (severity 5). (3) VICReg representations, clean data. (4) VICReg rep-
resentations, fog-corrupted (severity 5). (5) VICReg representations, fog-corrupted (severity
5) with fog noise (severity 1) injection during augmentation. Unlike supervised features,
VICReg representations degrade significantly under corruption (compare 3 and 4). Injecting
noise in the data augmentation (5) enhances class separability.))"

