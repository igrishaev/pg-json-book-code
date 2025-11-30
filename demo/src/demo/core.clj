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
    [{:db/ident :user/name
      :db/valueType :db.type/string
      :db/cardinality :db.cardinality/one}
     {:db/ident :user/age
      :db/valueType :db.type/long
      :db/cardinality :db.cardinality/one}
     {:db/ident :profile/user-ref
      :db/valueType :db.type/ref
      :db/cardinality :db.cardinality/one}
     {:db/ident :profile/job
      :db/valueType :db.type/string
      :db/cardinality :db.cardinality/one}
     {:db/ident :profile/is-open
      :db/valueType :db.type/boolean
      :db/cardinality :db.cardinality/one}])

  (d/transact conn {:tx-data schema})

  (def data
    [{:db/id "user1" :user/name "Ivan" :user/age 14}
     {:db/id "user2" :user/name "John" :user/age 34}
     {:db/id "user3" :user/name "Juan" :user/age 51}
     {:profile/user-ref "user1" :profile/job "teacher"    :profile/is-open true}
     {:profile/user-ref "user2" :profile/job "programmer" :profile/is-open false}
     {:profile/user-ref "user3" :profile/job "cook"       :profile/is-open true}])

  (d/transact conn {:tx-data data})

  (def query
    '[:find (pull ?u [*])
      :in $
      :where
      [?u :user/age ?age]
      [(> ?age 18)]
      [?p :profile/user-ref ?u]
      [?p :profile/is-open true]])

  (d/q query (d/db conn))

  [[{:db/id 96757023244368, :user/name "Juan", :user/age 51}]]


  )




(defn -main
  "I don't do a whole lot ... yet."
  [& args]
  (println "Hello, World!"))
