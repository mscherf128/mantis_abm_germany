extensions [gis]           ; load the GIS extension

globals [gadm-dataset mantis-dataset landcover-dataset ] ;elevation-dataset st-dataset ncols nrows  ; create a global variable to store our states dataset

patches-own [landcover-class] ; elevation st_2023]                    ; Variable to store the land cover class for each patch

mantis-own [age quantity]

breed [ mantis a-mantis ]


to custom-clear

  reset-ticks

  clear-turtles

  clear-patches

  clear-drawing

  clear-all-plots

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to load-datasets ; KM made this into a new button, to more easily debug the rest of the setup
  custom-clear


; Get the number of columns and rows from the dataset
;  set ncols gis:width-of elevation-dataset
;  set nrows gis:height-of elevation-dataset
;
;  ; Resize the NetLogo world to match the raster dimensions
;  resize-world 0 (ncols - 1) 0 (nrows - 1)
;
;  ; Optionally, adjust the patch size
;  set-patch-size 1

resize-world -30 30 -35 35
set-patch-size 8

  ; Einladen der tif-Datei scheint auf diese Weise nicht zu funktionieren, deshalb sind die Zeilen auskommentiert

  ; Load all of our datasets
  ;set elevation-dataset gis:load-dataset "elevation_10.asc"
  set gadm-dataset gis:load-dataset "data/gadm41_DEU_2.shp"
  set mantis-dataset gis:load-dataset "data/mantis_2022.shp"
  set landcover-dataset gis:load-dataset "data/CORINE_2018.shp"


  ; Set the world envelope to the union of all of our dataset's envelopes
  gis:set-world-envelope (gis:envelope-union-of (gis:envelope-of gadm-dataset)
                                                (gis:envelope-of mantis-dataset)
                                                (gis:envelope-of landcover-dataset))
                                               ;(gis:envelope-of elevation-dataset)

; GADM-Daten (Landkreise Deutschlands) in die Welt zeichnen
 gis:set-drawing-color white
 gis:draw gadm-dataset 0.5

; Der folgende auskommentierte Teil war ein Versuch die landcover-Daten als Patches darzustellen, hat aber leider nicht funktioniert
; mit dem nachfolgenden Code sind dann alle Patches gelb
; KM: erste Zeile wieder einkommentiert, für den Rest eine Alternative gecoded, siehe weiter unten
 ; Assign land cover classes to patches
gis:apply-coverage landcover-dataset "CODE_18" landcover-class

;gis:apply-raster elevation-dataset elevation

end ; KM added this line


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to setup ; KM added this line

; alle mantis aus vorheriger Simulation löschen
    ask mantis [die]


  ; den patches die landcover-class zuordnen
   ask patches[
    if is-string? landcover-class [set pcolor read-from-string landcover-class mod 140]
  ]
    ; KM: colors are coded with numbers between 0 and <140 in NetLogo;
    ;     read-from-string turns strings into numbers;
    ;     mod gives the remainder of an integer division;
    ;     mod is needed, because the code in CODE_18 can be larger than 140;
    ;     instead of the mod-version, colors can also be individually assigned, e.g.
    ;       if read-from-string landcover-class == 211 [set pcolor pink] ; and so on ...


; Den patches den Wert der Geländehhöhe aus der Raster-Datei zuweisen -> funktioniert leider nicht; ich bin nicht sicher was ich einsetzen muss oder ob die Syntax falsch ist

;ask patches[
;set elevation
;    let value gis:raster-sample elevation-dataset pxcor pycor
;    if value != "-9999" elevation-dataset
;  [set elevation scale-color green value (gis:minimum-of elevation (gis:maximum-of elevation)
;      [set pcolor white
;      ]
;    ]
;  ]

   ; gis:paint elevation-dataset 0

; Erstellen der Gottesanbeterinnen-turtles aus den Daten der Gottesanbeterinnen shape-Datei
  foreach gis:feature-list-of mantis-dataset [ this-mantis-vector-feature -> ; foreach VectorFeature in the mantis dataset
    let location gis:location-of gis:centroid-of this-mantis-vector-feature  ; get the location of its center in NetLogo world-space

    create-mantis 1 [                                          ; create a mantis
      set color green
      set shape "bug"
      set size 1
      set age 0

      set xcor item 0 location                                   ; set its xcor to the x coordinate of the mantis
      set ycor item 1 location                                   ; set its ycor to the y coordinate of the mantis
    ]
  ]

  export-view "outputs/mantis_spread_0.png"

  reset-ticks
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; go-Prozedur
to go
  reproduce
  death
  move
  ageing
  export

  tick ; zähle einen Schritt in der Simulation voran
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1. Regel: Nachkommen produzieren
to reproduce
  ask mantis [
    hatch 2[                         ; jede vorjährige mantis produziert 1 Nachkomme an der gleichen Stelle
      set age 0                      ; Nachkommen sind alle 0 alt
    ]
  ]
end

; 2. Regel: vorjährige mantis sterben
to death
  ask mantis [
    if age = 1 [ die ]
  ]
end

;> names(LC_100)
;[1] "Discontinuous urban fabric"
;[2] "Non-irrigated arable land"
;[3] "Vineyards"
;[4] "Pastures"
;[5] "Land principally occupied by agriculture, with significant areas of natural vegetation"
;[6] "Broad-leaved forest"
;[7] "Coniferous forest"
;[8] "Mixed forest"

;> names(LC_200)
;[1] "Discontinuous urban fabric" "Non-irrigated arable land"  "Vineyards"   "Pastures"
;[5] "Broad-leaved forest"        "Coniferous forest"

;> names(LC_300)
;[1] "Discontinuous urban fabric" "Non-irrigated arable land"  "Pastures"

;> names(LC_350)
;[1] "Discontinuous urban fabric"

to move
  ask mantis [
    let urban one-of neighbors with [landcover-class = "112"]
    ifelse urban != nobody[
      move-to urban
    ]
    [let three-patch one-of neighbors with [landcover-class = "211" or landcover-class = "231"]
    ifelse three-patch != nobody and random 100.5 > 20 [
      move-to three-patch
     ]
      [let two-patch one-of neighbors with [landcover-class = "221" or landcover-class = "311" or landcover-class = "312"]
    ifelse two-patch != nobody and random 100.5 > 40 [
      move-to two-patch
      ]
      [let one-patch one-of neighbors with [landcover-class = "243" or landcover-class = "313"]
    ifelse one-patch != nobody and random 100.5 > 60 [
      move-to one-patch
      ]
     [let zero-patch one-of neighbors with [
landcover-class = "111" or landcover-class = "121" or landcover-class = "122" or landcover-class = "123" or landcover-class = "124" or landcover-class = "131" or landcover-class = "132" or landcover-class = "133" or landcover-class = "141" or landcover-class = "142" or landcover-class = "222" or landcover-class = "242" or landcover-class = "321" or landcover-class = "322" or landcover-class = "324" or landcover-class = "333" or landcover-class = "411" or landcover-class = "412" or landcover-class = "511" or landcover-class = "512" or landcover-class = "331" or landcover-class = "332" or landcover-class = "335" or landcover-class = "421" or landcover-class = "423" or landcover-class = "521" or landcover-class = "522" or landcover-class = "523"
            ]
      if zero-patch != nobody and random 100.5 > 80 [
      move-to zero-patch
          ]
    ]
   ]
  ]
  ]
  ]

end

; 4. Regel: diesjährige mantis altern um 1
to ageing
  ask mantis [
    set age age + 1
  ]

end

to export
  if ticks = 1
  [export-view "outputs/mantis_spread_1.png"
   gis:store-dataset mantis-dataset "data/mantis_2023_modeled.shp"]
;  ifelse ticks = 1
;  [export-view "mantis_spread_1.png"
;   gis:store-dataset mantis-dataset "mantis_2023_modeled.shp"]
; [ifelse ticks = 5
;  [export-view "mantis_spread_5.png"]
;   [ifelse ticks = 10
;    [export-view "mantis_spread_10.png"]
;    [ifelse ticks = 15
;      [export-view "mantis_spread_15.png"]
;     [ifelse ticks = 20
;        [export-view "mantis_spread_20.png"]
;      [ifelse ticks = 25
;          [export-view "mantis_spread_25.png"]
;       [if ticks = 30
;        [export-view "mantis_spread_30.png"]
;]]]]]]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
706
587
-1
-1
8.0
1
10
1
1
1
0
1
1
1
-30
30
-35
35
1
1
1
ticks
30.0

BUTTON
28
58
91
91
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
110
58
173
91
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
28
10
174
43
Load datasets
load-datasets
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
