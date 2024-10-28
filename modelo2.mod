# Conjunto de aviones
set AVIONES;

# Conjunto de pistas
set PISTAS;

# Conjunto de slots de tiempo
set SLOTS;

# Hora de llegada de cada avión (en minutos desde la medianoche)
param hora_llegada{a in AVIONES};

# Hora límite para cada avión (en minutos desde la medianoche)
param hora_limite{a in AVIONES};

# Coste adicional por minuto de retraso para cada avión
param coste_retraso{c in AVIONES}, >= 0;

# Hora posible de llegada de cada slot 
param posible_hora_llegada {s in SLOTS};                                

# Disponibilidad de cada pista en cada slot de tiempo (1 si está libre, 0 si está ocupado)
param disponibilidad {p in PISTAS, s in SLOTS}, binary;   

# Valor muy grande, big-M
param big_M;   

# Variable binaria que indica si el avión a aterriza en la pista p en el slot t
var x{a in AVIONES, p in PISTAS, s in SLOTS}, binary;

# Función objetivo: minimizar el coste adicional por retrasos
minimize Coste_Total:
    sum{a in AVIONES, p in PISTAS, s in SLOTS} 
        coste_retraso[a] * (posible_hora_llegada[s] - hora_llegada[a]) * x[a,p,s];


# Restricción 1: Cada avión debe aterrizar en un único slot de tiempo en alguna pista
subject to Unico_Slot_Por_Avion{a in AVIONES}:
    sum{p in PISTAS, s in SLOTS} x[a, p, s] = 1;

# Restricción 2: Solo un avión puede aterrizar en cada slot de una pista
subject to Unico_Avion_Por_Slot{p in PISTAS, s in SLOTS}:
    sum{a in AVIONES} x[a, p, s] <= 1;

# Restricción 3: El slot de aterrizaje debe estar libre
subject to Slot_Libre {a in AVIONES, p in PISTAS, s in SLOTS}:
    x[a, p, s] <= disponibilidad[p, s];

# Restricción 4: El slot de aterrizaje debe comenzar después de la llegada del avión
subject to Llegada_Despues_Hora{a in AVIONES, p in PISTAS, s in SLOTS}:
    posible_hora_llegada[s] >= hora_llegada[a] - big_M * (1 - x[a,p,s]);

# Restricción 5: El slot de aterrizaje debe estar dentro del límite de tiempo de aterrizaje
subject to Limite_Tiempo{a in AVIONES, p in PISTAS, s in SLOTS}:
    posible_hora_llegada[s] <= hora_limite[a] + big_M * (1 - x[a,p,s]);

# Restricción 6: Si un avión aterriza en el slot t de la pista p, el siguiente slot t+1 no puede ser ocupado por ningún avión
s.t. No_Slots_Consecutivos {a in AVIONES, p in PISTAS, s in 1..6}:
    x[a,p,s] + x[a,p,s+1] <= 1;

# Fin del modelo
end;


