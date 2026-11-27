"""Encoder (backbone + projecteur) et Adapter pour les modèles venus d'ailleurs.

Contrat commun : features(x) -> (feat, emb). feat est ce qu'on évalue, emb ce que reçoit le projecteur.
Tout ce qui respecte ce contrat passe dans l'évaluation : notre Encoder, le code officiel,
un timm pré-entraîné, un réseau non entraîné (le plancher).
"""
