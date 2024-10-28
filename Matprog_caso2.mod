# Modelo de asignación de slots de aterrizaje para aviones
set AIRPLANE;  # Conjunto de aviones
set RUNWAY;  # Conjunto de pistas
set SLOT;   # Conjunto de slots de tiempo (horas reales)

param scheduled_arrival {a in AIRPLANE};                                # Hora programada de llegada de cada avión (horas reales)
param landing_deadline {a in AIRPLANE};                                 # Hora límite de aterrizaje de cada avión (horas reales)
param delay_cost {c in AIRPLANE}, >= 0;                                 # Coste por minuto de retraso de cada avión, siempre positivo
param possible_arrival_time {s in SLOT};                                # Hora posible de llegada de cada slot (horas reales)
param slot_availability {r in RUNWAY, s in SLOT}, binary;               # Disponibilidad de cada slot de tiempo en cada pista
param big_M;                                                            # Valor muy grande, big-M

# Variables
var availability{a in AIRPLANE, r in RUNWAY, s in SLOT}, binary;  # Variable binaria: 1 si el avión aterriza en el slot t de la pista p

# Función objetivo: Minimizar el coste total de los retrasos
minimize TotalCost:
    sum {a in AIRPLANE, r in RUNWAY, s in SLOT} delay_cost[a] * (possible_arrival_time[s] - scheduled_arrival[a]) * availability[a,r,s];

# Restricciones

# Restricción 1: Cada avión debe aterrizar exactamente una vez
s.t. OneLanding {a in AIRPLANE}:
    sum {r in RUNWAY, s in SLOT} availability[a,r,s] = 1;

# Restricción 2: Un slot solo puede estar asignado a un avión
s.t. OnePlanePerSlot {r in RUNWAY, s in SLOT}:
    sum {a in AIRPLANE} availability[a,r,s] <= 1;

# Restricción 3: Solo se pueden asignar slots disponibles
s.t. SlotAvailability {a in AIRPLANE, r in RUNWAY, s in SLOT}:
    availability[a,r,s] <= slot_availability[r,s];

# Restricción 4: El slot debe ser igual o posterior a la hora de llegada programada
s.t. AfterArrival {a in AIRPLANE, r in RUNWAY, s in SLOT}:
    possible_arrival_time[s] >= scheduled_arrival[a] - big_M * (1 - availability[a,r,s]);

# Restricción 5: El slot debe ser igual o anterior a la hora límite de aterrizaje
s.t. BeforeDeadline {a in AIRPLANE, r in RUNWAY, s in SLOT}:
    possible_arrival_time[s] <= landing_deadline[a] + big_M * (1 - availability[a,r,s]);

# Restricción 6: Si un avión aterriza en el slot t de la pista p, el siguiente slot t+1 no puede ser ocupado por ningún avión
s.t. NoConsecutiveSlots {a in AIRPLANE, r in RUNWAY, s in 1..6}:
    availability[a,r,s] + availability[a,r,s+1] <= 1;

end;