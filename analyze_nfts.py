#!/usr/bin/env python3
import os

files = [f for f in os.listdir('build/images') if f.endswith('.png')]
nums = sorted([int(f.replace('.png','')) for f in files])

print(f'NFTs générés: {len(nums)}')
print(f'Index min: {min(nums)}')
print(f'Index max: {max(nums)}')
print(f'Objectif: 300 (indices 0-299)')
print(f'Manquants: {300 - len(nums)}')

if max(nums) < 100:
    tier = "Poor (0-99)"
elif max(nums) < 200:
    tier = "Mid (100-199)"
else:
    tier = "Rich (200-299)"
    
print(f'Dernier tier atteint: {tier}')

# Calcul des combinaisons possibles
combinations = 7 * 2 * 2 * 5 * 3 * 3 * 5 * 7
print(f'\nCombinaisons théoriques: {combinations:,}')
print(f'Pourcentage utilisé: {(len(nums) / combinations) * 100:.2f}%')
