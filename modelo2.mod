# Conjunto de aviones
set AVIONES;

# Conjunto de pistas
set PISTAS;

# Conjunto de slots de tiempo
set SLOTS;

# Hora de llegada de cada avión (en minutos desde la medianoche)
param hora_llegada{AVIONES};

# Hora límite para cada avión (en minutos desde la medianoche)
param hora_limite{AVIONES};

# Coste adicional por minuto de retraso para cada avión
param coste_retraso{AVIONES};

# Disponibilidad de cada pista en cada slot de tiempo (1 si está libre, 0 si está ocupado)
param disponibilidad{PISTAS, SLOTS}, binary;

# Variable binaria que indica si el avión a aterriza en la pista p en el slot t
var x{a in AVIONES, p in PISTAS, t in SLOTS}, binary;

# Función objetivo: minimizar el coste adicional por retrasos
minimize Coste_Total:
    sum{a in AVIONES, p in PISTAS, t in SLOTS}
        (if t * 15 >= hora_llegada[a] then (t * 15 - hora_llegada[a]) * coste_retraso[a] else 0) * x[a, p, t];

# Restricción: Cada avión debe aterrizar en un único slot de tiempo en alguna pista
subject to Unico_Slot_Por_Avion{a in AVIONES}:
    sum{p in PISTAS, t in SLOTS} x[a, p, t] = 1;

# Restricción: Solo un avión puede aterrizar en cada slot de una pista
subject to Unico_Avion_Por_Slot{p in PISTAS, t in SLOTS}:
    sum{a in AVIONES} x[a, p, t] <= 1;

# Restricción: El slot de aterrizaje debe estar libre
subject to Slot_Libre{a in AVIONES, p in PISTAS, t in SLOTS}:
    x[a, p, t] <= disponibilidad[p, t];

# Restricción: El slot de aterrizaje debe comenzar después de la llegada del avión
subject to Llegada_Despues_Hora{a in AVIONES, p in PISTAS, t in SLOTS}:
    if (t * 15) < hora_llegada[a] then x[a, p, t] = 0;

# Restricción: El slot de aterrizaje debe estar dentro del límite de tiempo de aterrizaje
subject to Limite_Tiempo{a in AVIONES, p in PISTAS, t in SLOTS}:
    if (t * 15) > hora_limite[a] then x[a, p, t] = 0;

# Fin del modelo
end;


