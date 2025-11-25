(def users
  [{:id 1 :name "Ivan" :age 14}
   {:id 2 :name "John" :age 34}
   {:id 3 :name "Juan" :age 51}])

(->> users
     (filter (fn [user]
               (-> user :age (> 18))))
     (map (fn [user]
            (select-keys user [:id :name]))))

({:id 2 :name "John"}
 {:id 3 :name "Juan"})

(def profiles
  [{:user-id 1 :job "teacher" :is-open true}
   {:user-id 2 :job "programmer" :is-open false}
   {:user-id 3 :job "cook" :is-open true}])

(defn index-by [kw rows]
  (->> rows
       (map (juxt kw identity))
       (into {})))

(def profile-index
  (index-by :user-id profiles))

(->> users
     (filter (fn [user]
               (-> user :age (> 18))))
     (map (fn [user]
            (let [profile (get profile-index (:id user))]
              (merge user profile))))
     (filter (fn [row]
               (-> row :is-open))))

({:id 3,
  :name "Juan",
  :age 51,
  :user-id 3,
  :job "cook",
  :is-open true})

[:where

 [?u :user/id

  :]


]
