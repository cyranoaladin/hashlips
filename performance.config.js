/**
 * CONFIGURATION DE PERFORMANCE
 * Ajustez ces valeurs pour éviter les crashs selon votre système
 */

module.exports = {
    // Nombre de NFTs à générer avant de faire une pause
    // Réduisez si vous avez peu de RAM (ex: 25 pour 8GB RAM, 50 pour 16GB RAM)
    BATCH_SIZE: 50,
    
    // Délai en millisecondes entre chaque lot
    // Augmentez si vous continuez à crasher (ex: 3000-5000ms)
    BATCH_DELAY: 2000,
    
    // Sauvegarde des métadonnées tous les X NFTs
    // Permet de ne pas tout perdre en cas de crash
    SAVE_METADATA_INTERVAL: 100,
    
    // Active le garbage collector manuel (nécessite node --expose-gc)
    // Aide à libérer la mémoire entre les lots
    FORCE_GC: true,
    
    // Affiche les statistiques mémoire
    SHOW_MEMORY_STATS: true,
};
