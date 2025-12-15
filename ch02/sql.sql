

update profiles
set extra_data['email_activated'] = true
where ...


update profiles
set extra_data['achievement_old_timer'] = true
where created_at > '2000-01-01'::date
