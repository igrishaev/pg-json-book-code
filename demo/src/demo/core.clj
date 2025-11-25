(ns demo.core
  (:require
   [datomic.client.api :as d]))


(comment

  (def client
    (d/client {:server-type :datomic-local
               :storage-dir :mem
               :system "demo"}))

  (d/create-database client {:db-name "demo"})

  (def conn
    (d/connect client {:db-name "demo"}))

  (def schema
    [{:db/ident :user/id
      :db/valueType :db.type/long
      :db/cardinality :db.cardinality/one}
     {:db/ident :user/name
      :db/valueType :db.type/string
      :db/cardinality :db.cardinality/one}
     {:db/ident :user/age
      :db/valueType :db.type/long
      :db/cardinality :db.cardinality/one}
     {:db/ident :profile/user-id
      :db/valueType :db.type/long
      :db/cardinality :db.cardinality/one}
     {:db/ident :profile/job
      :db/valueType :db.type/string
      :db/cardinality :db.cardinality/one}
     {:db/ident :profile/is-open
      :db/valueType :db.type/boolean
      :db/cardinality :db.cardinality/one}])

  (d/transact conn {:tx-data schema})

  (def data
    [{:user/id 1 :user/name "Ivan" :user/age 14}
     {:user/id 2 :user/name "John" :user/age 34}
     {:user/id 3 :user/name "Juan" :user/age 51}
     {:profile/user-id 1 :profile/job "teacher"    :profile/is-open true}
     {:profile/user-id 2 :profile/job "programmer" :profile/is-open false}
     {:profile/user-id 3 :profile/job "cook"       :profile/is-open true}])

  (d/transact conn {:tx-data data})

  (def query
    '[:find (pull ?u [*]) (pull ?p [*])
      :in $
      :where
      [?u :user/id ?id]
      [?u :user/age ?age]
      [(> ?age 18)]
      [?p :profile/user-id ?id]
      [?p :profile/is-open ?open]
      [(= ?open true)]])

  (d/q query (d/db conn))

  [[{:db/id 83562883711057, :user/id 3, :user/name "Juan", :user/age 51}
    {:db/id 83562883711060,
     :profile/user-id 3,
     :profile/job "cook",
     :profile/is-open true}]]


  )




(defn -main
  "I don't do a whole lot ... yet."
  [& args]
  (println "Hello, World!"))
