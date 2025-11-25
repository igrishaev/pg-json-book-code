(ns demo.core
  (:require
   [datomic.client.api :as d]))


(def client (d/client {:server-type :datomic-local
                       :storage-dir :mem
                       :system "demo"}))

(d/list-databases client {})


(defn -main
  "I don't do a whole lot ... yet."
  [& args]
  (println "Hello, World!"))
