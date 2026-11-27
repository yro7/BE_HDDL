"""Extraction des features d'un backbone gelé, avec cache sur disque.

Clé du cache : checkpoint, dataset, split, corruption, sévérité, seed.
On extrait une fois, ensuite kNN, probe, CKA et t-SNE relisent le cache.
"""
