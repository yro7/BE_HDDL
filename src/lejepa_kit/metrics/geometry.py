"""Structure du latent space.

- RankMe : rang effectif, pour repérer un effondrement
- statistique SIGReg sur feat (la loss ne contraint que la projection en n dims)
- invariance : cos(f(x), f(c(x))) entre une image propre et sa version corrompue
- CKA linéaire : de combien la représentation bouge quand la sévérité monte
- silhouette, dans l'espace des features et jamais dans le plan du t-SNE
"""
