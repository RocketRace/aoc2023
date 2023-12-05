(ns five.core
  (:require [clojure.string :as str]))

(defn split-space [s]
  (str/split s #" "))

(def input (slurp "input"))

(def sections (str/split input #"\n\n"))

(def seeds
  (map parse-long
       (rest (split-space (first sections)))))

(defrecord Mapping [dest src length])

(def maps
  (map (fn [section]
         (map #(apply ->Mapping (map parse-long %))
              (rest (map split-space (str/split-lines section)))))
       (rest sections)))

maps

(defn offset [mapping]
  (- (get mapping :dest) (get mapping :src)))

(defn translate-layer [section number]
  (if-let
   [translation (seq (filter (fn [mapping]
                               (let [start (get mapping :src)
                                     end (+ start (get mapping :length))]
                                 (and (<= start number) (> end number))))
                             section))]
    (+ number (offset (first translation)))
    number))

(def part1
  (apply min
         (reduce (fn [prev-list layer]
                   (map #(translate-layer layer %) prev-list))
                 seeds maps)))

(defrecord Range [start length])

(def real-seeds (map #(apply ->Range %) (partition 2 seeds)))

;; assumes the intersection is nonempty!
(defn intersects? [mapping range]
  (let [range-start (get range :start)
        range-end (+ range-start (get range :length))
        map-start (get mapping :src)
        map-end (+ map-start (get mapping :length))
        max-start (max range-start map-start)
        min-end (min range-end map-end)]
    (< max-start min-end)))

(defn intersection [mapping range]
  (let [range-start (get range :start)
        range-end (+ range-start (get range :length))
        map-start (get mapping :src)
        map-end (+ map-start (get mapping :length))
        max-start (max range-start map-start)
        min-end (min range-end map-end)]
    (Range. max-start (- min-end max-start))))

;; after intersection
(defn conj-if [cond big small]
  (if cond (conj big small) big))

(defn without-intersection [mapping range]
  (if (intersects? mapping range)
    (let [inter (intersection mapping range)
          range-start (get range :start)
          range-end (+ range-start (get range :length))
          inter-start (get inter :start)
          inter-end (+ inter-start (get inter :length))]
      (conj-if (< inter-end range-end)
               (if (< range-start inter-start)
                 [(Range. range-start (- inter-start range-start))]
                 [])
               (Range. inter-end (- range-end inter-end))))
    [range]))

(defn without-all-intersections [mappings range]
  (reduce
   (fn [ranges mapping] (flatten (map #(without-intersection mapping %) ranges)))
   [range]
   mappings))

(defn apply-offset [mapping range]
  (assoc range :start (+ (get range :start) (offset mapping))))

(defn translate-layer-range [layer range]
  (if-let [overlaps
           (seq (filter
                 (fn [mapping] (intersects? mapping range))
                 layer))]
    (flatten [(without-all-intersections overlaps range)
              (map
               (fn [mapping] (apply-offset mapping (intersection mapping range)))
               overlaps)])
    [range]))

(def part2
  (apply min (map #(get % :start)
                  (reduce (fn [prev-list layer]
                            (flatten (map #(translate-layer-range layer %) prev-list)))
                          real-seeds maps))))

part1

part2
