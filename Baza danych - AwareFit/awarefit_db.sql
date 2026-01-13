--
-- PostgreSQL database dump
--

\restrict 2bfLs3J59zqLM9lrANlt2fbZL0BrtB1nmOOtz8XTLrDSLPZjIbtqsTieemJcxn0

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

-- Started on 2026-01-13 18:55:39

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 6 (class 2615 OID 24751)
-- Name: crud; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA crud;


ALTER SCHEMA crud OWNER TO postgres;

--
-- TOC entry 4 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: pg_database_owner
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO pg_database_owner;

--
-- TOC entry 5135 (class 0 OID 0)
-- Dependencies: 4
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- TOC entry 272 (class 1255 OID 24780)
-- Name: calculate_workout_streak(integer, integer); Type: FUNCTION; Schema: crud; Owner: postgres
--

CREATE FUNCTION crud.calculate_workout_streak(p_user_id integer, p_max_break_days integer DEFAULT 4) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    streak_count integer := 0;
    last_workout_date date;
    current_workout_record RECORD;
BEGIN
    -- Pobieramy daty unikalnych dni treningowych użytkownika, od najnowszych
    FOR current_workout_record IN 
        SELECT DISTINCT date::date as w_date 
        FROM public.workouts 
        WHERE user_id = p_user_id 
        ORDER BY w_date DESC
    LOOP
        IF last_workout_date IS NULL THEN
            -- Pierwszy (najnowszy) trening rozpoczyna licznik
            streak_count := 1;
        ELSE
            -- Sprawdzamy różnicę dni między obecnym a poprzednim (późniejszym) treningiem
            IF (last_workout_date - current_workout_record.w_date) <= p_max_break_days THEN
                streak_count := streak_count + 1;
            ELSE
                -- Przerwa była za długa (np. > 4 dni), przerywamy pętlę
                EXIT;
            END IF;
        END IF;
        
        last_workout_date := current_workout_record.w_date;
    END LOOP;

    RETURN streak_count;
END;
$$;


ALTER FUNCTION crud.calculate_workout_streak(p_user_id integer, p_max_break_days integer) OWNER TO postgres;

--
-- TOC entry 236 (class 1255 OID 24767)
-- Name: delete_body_measurement(integer); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.delete_body_measurement(IN p_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM public.body_measurements WHERE id = p_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Nie znaleziono pomiaru o ID %', p_id; END IF;
END;
$$;


ALTER PROCEDURE crud.delete_body_measurement(IN p_id integer) OWNER TO postgres;

--
-- TOC entry 259 (class 1255 OID 24763)
-- Name: delete_exercise(integer); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.delete_exercise(IN p_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM public.exercises WHERE id = p_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Nie znaleziono ćwiczenia o ID %', p_id; END IF;
END;
$$;


ALTER PROCEDURE crud.delete_exercise(IN p_id integer) OWNER TO postgres;

--
-- TOC entry 255 (class 1255 OID 24759)
-- Name: delete_muscle_group(integer); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.delete_muscle_group(IN p_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    BEGIN
        DELETE FROM public.muscle_groups WHERE id = p_id;
        IF NOT FOUND THEN RAISE EXCEPTION 'Nie znaleziono grupy o ID %', p_id; END IF;
    EXCEPTION WHEN foreign_key_violation THEN 
        RAISE EXCEPTION 'Nie można usunąć grupy - są do niej przypisane ćwiczenia';
    END;
END;
$$;


ALTER PROCEDURE crud.delete_muscle_group(IN p_id integer) OWNER TO postgres;

--
-- TOC entry 251 (class 1255 OID 24755)
-- Name: delete_user(integer); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.delete_user(IN p_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.users WHERE id = p_id) THEN 
        RAISE EXCEPTION 'Użytkownik o ID % nie istnieje', p_id; 
    END IF;
    
    BEGIN
        DELETE FROM public.users WHERE id = p_id;
    EXCEPTION WHEN foreign_key_violation THEN 
        RAISE EXCEPTION 'Nie można usunąć użytkownika - posiada powiązane dane w innych tabelach';
    END;
END;
$$;


ALTER PROCEDURE crud.delete_user(IN p_id integer) OWNER TO postgres;

--
-- TOC entry 263 (class 1255 OID 24771)
-- Name: delete_workout(integer); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.delete_workout(IN p_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM public.workouts WHERE id = p_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Nie znaleziono treningu o ID %', p_id; END IF;
END;
$$;


ALTER PROCEDURE crud.delete_workout(IN p_id integer) OWNER TO postgres;

--
-- TOC entry 267 (class 1255 OID 24775)
-- Name: delete_workout_exercise(integer); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.delete_workout_exercise(IN p_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM public.workout_exercises WHERE id = p_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Wpis o ID % nie istnieje', p_id; END IF;
END;
$$;


ALTER PROCEDURE crud.delete_workout_exercise(IN p_id integer) OWNER TO postgres;

--
-- TOC entry 271 (class 1255 OID 24779)
-- Name: delete_workout_set(integer); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.delete_workout_set(IN p_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM public.workout_sets WHERE id = p_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Seria o ID % nie istnieje', p_id; END IF;
END;
$$;


ALTER PROCEDURE crud.delete_workout_set(IN p_id integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 227 (class 1259 OID 16431)
-- Name: body_measurements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.body_measurements (
    id integer NOT NULL,
    user_id integer NOT NULL,
    date timestamp without time zone NOT NULL,
    height double precision,
    weight double precision,
    chest double precision,
    waist double precision,
    biceps double precision,
    thighs double precision,
    hips double precision,
    neck numeric,
    goal character varying(50) DEFAULT 'Rekompozycja'::character varying,
    activity_level numeric(4,3) DEFAULT 1
);


ALTER TABLE public.body_measurements OWNER TO postgres;

--
-- TOC entry 5136 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN body_measurements.activity_level; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.body_measurements.activity_level IS '1:Siedzący, 2:Lekka, 3:Średnia, 4:Wysoka, 5:Ekstremalna';


--
-- TOC entry 260 (class 1255 OID 24764)
-- Name: get_all_body_measurements(); Type: FUNCTION; Schema: crud; Owner: postgres
--

CREATE FUNCTION crud.get_all_body_measurements() RETURNS SETOF public.body_measurements
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT * FROM public.body_measurements;
END;
$$;


ALTER FUNCTION crud.get_all_body_measurements() OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16414)
-- Name: exercises; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.exercises (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    muscle_group_id integer NOT NULL
);


ALTER TABLE public.exercises OWNER TO postgres;

--
-- TOC entry 256 (class 1255 OID 24760)
-- Name: get_all_exercises(); Type: FUNCTION; Schema: crud; Owner: postgres
--

CREATE FUNCTION crud.get_all_exercises() RETURNS SETOF public.exercises
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT * FROM public.exercises;
END;
$$;


ALTER FUNCTION crud.get_all_exercises() OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16405)
-- Name: muscle_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.muscle_groups (
    id integer NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE public.muscle_groups OWNER TO postgres;

--
-- TOC entry 252 (class 1255 OID 24756)
-- Name: get_all_muscle_groups(); Type: FUNCTION; Schema: crud; Owner: postgres
--

CREATE FUNCTION crud.get_all_muscle_groups() RETURNS SETOF public.muscle_groups
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT * FROM public.muscle_groups;
END;
$$;


ALTER FUNCTION crud.get_all_muscle_groups() OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16390)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(50) NOT NULL,
    password character varying(255) NOT NULL,
    email character varying(100) NOT NULL,
    first_name character varying(50) NOT NULL,
    last_name character varying(50) NOT NULL,
    gender text,
    CONSTRAINT users_gender_check CHECK ((gender = ANY (ARRAY['Male'::text, 'Female'::text])))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 235 (class 1255 OID 24752)
-- Name: get_all_users(); Type: FUNCTION; Schema: crud; Owner: postgres
--

CREATE FUNCTION crud.get_all_users() RETURNS SETOF public.users
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT * FROM public.users;
END;
$$;


ALTER FUNCTION crud.get_all_users() OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 16461)
-- Name: workout_exercises; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.workout_exercises (
    id integer NOT NULL,
    workout_id integer NOT NULL,
    exercise_id integer NOT NULL
);


ALTER TABLE public.workout_exercises OWNER TO postgres;

--
-- TOC entry 264 (class 1255 OID 24772)
-- Name: get_all_workout_exercises(); Type: FUNCTION; Schema: crud; Owner: postgres
--

CREATE FUNCTION crud.get_all_workout_exercises() RETURNS SETOF public.workout_exercises
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT * FROM public.workout_exercises;
END;
$$;


ALTER FUNCTION crud.get_all_workout_exercises() OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 16481)
-- Name: workout_sets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.workout_sets (
    id integer NOT NULL,
    workout_exercise_id integer NOT NULL,
    weight double precision,
    reps integer NOT NULL,
    set_number integer NOT NULL
);


ALTER TABLE public.workout_sets OWNER TO postgres;

--
-- TOC entry 268 (class 1255 OID 24776)
-- Name: get_all_workout_sets(); Type: FUNCTION; Schema: crud; Owner: postgres
--

CREATE FUNCTION crud.get_all_workout_sets() RETURNS SETOF public.workout_sets
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT * FROM public.workout_sets;
END;
$$;


ALTER FUNCTION crud.get_all_workout_sets() OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16446)
-- Name: workouts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.workouts (
    id integer NOT NULL,
    user_id integer NOT NULL,
    date timestamp without time zone NOT NULL,
    duration interval
);


ALTER TABLE public.workouts OWNER TO postgres;

--
-- TOC entry 5137 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN workouts.duration; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.workouts.duration IS 'Czas trwania sesji treningowej';


--
-- TOC entry 237 (class 1255 OID 24768)
-- Name: get_all_workouts(); Type: FUNCTION; Schema: crud; Owner: postgres
--

CREATE FUNCTION crud.get_all_workouts() RETURNS SETOF public.workouts
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT * FROM public.workouts;
END;
$$;


ALTER FUNCTION crud.get_all_workouts() OWNER TO postgres;

--
-- TOC entry 290 (class 1255 OID 24813)
-- Name: get_user_training_stats(integer); Type: FUNCTION; Schema: crud; Owner: postgres
--

CREATE FUNCTION crud.get_user_training_stats(p_user_id integer) RETURNS TABLE(workout_id integer, muscle_group_name text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT w.id, mg.name::text
    FROM public.workouts w
    JOIN public.workout_exercises we ON w.id = we.workout_id
    JOIN public.exercises e ON we.exercise_id = e.id
    JOIN public.muscle_groups mg ON e.muscle_group_id = mg.id
    WHERE w.user_id = p_user_id AND w.date > NOW() - INTERVAL '30 days';
END;
$$;


ALTER FUNCTION crud.get_user_training_stats(p_user_id integer) OWNER TO postgres;

--
-- TOC entry 293 (class 1255 OID 24815)
-- Name: insert_body_measurement(integer, timestamp without time zone, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, text, text); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.insert_body_measurement(IN p_user_id integer, IN p_date timestamp without time zone, IN p_height double precision, IN p_weight double precision, IN p_chest double precision, IN p_waist double precision, IN p_biceps double precision, IN p_thighs double precision, IN p_hips double precision, IN p_neck double precision, IN p_goal text, IN p_activity_lvl text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Istniejące walidacje
    IF p_height < 50 OR p_height > 250 THEN RAISE EXCEPTION 'Wzrost poza realistycznym zakresem (50-250)'; END IF;
    IF p_weight < 30 OR p_weight > 300 THEN RAISE EXCEPTION 'Waga poza realistycznym zakresem (30-300)'; END IF;
    IF p_date > NOW() THEN RAISE EXCEPTION 'Data pomiaru nie może być z przyszłości'; END IF;
    
    -- Rozszerzona walidacja obwodów (dodano p_neck, p_thighs, p_hips)
    IF p_chest <= 0 OR p_waist <= 0 OR p_biceps <= 0 OR p_neck <= 0 OR p_thighs <= 0 OR p_hips <= 0 THEN 
        RAISE EXCEPTION 'Wszystkie obwody (klatka, talia, biceps, szyja, uda, biodra) muszą być większe od 0'; 
    END IF;

    -- Walidacja nowych pól tekstowych
    IF p_goal IS NULL OR p_goal = '' THEN RAISE EXCEPTION 'Cel nie może być pusty'; END IF;
    IF p_activity_lvl IS NULL OR p_activity_lvl = '' THEN RAISE EXCEPTION 'Poziom aktywności nie może być pusty'; END IF;

    -- Wstawianie danych do tabeli public.body_measurements
    INSERT INTO public.body_measurements (
        user_id, date, height, weight, chest, waist, biceps, thighs, hips, neck, goal, activity_lvl
    )
    VALUES (
        p_user_id, p_date, p_height, p_weight, p_chest, p_waist, p_biceps, p_thighs, p_hips, p_neck, p_goal, p_activity_lvl
    );
END;
$$;


ALTER PROCEDURE crud.insert_body_measurement(IN p_user_id integer, IN p_date timestamp without time zone, IN p_height double precision, IN p_weight double precision, IN p_chest double precision, IN p_waist double precision, IN p_biceps double precision, IN p_thighs double precision, IN p_hips double precision, IN p_neck double precision, IN p_goal text, IN p_activity_lvl text) OWNER TO postgres;

--
-- TOC entry 275 (class 1255 OID 24820)
-- Name: insert_body_measurement(integer, timestamp without time zone, double precision, double precision, double precision, double precision, double precision, double precision, double precision, numeric, character varying, numeric); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.insert_body_measurement(IN p_user_id integer, IN p_date timestamp without time zone, IN p_height double precision, IN p_weight double precision, IN p_chest double precision, IN p_waist double precision, IN p_biceps double precision, IN p_thighs double precision, IN p_hips double precision, IN p_neck numeric, IN p_goal character varying, IN p_activity_lvl numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public.body_measurements (
        user_id, date, height, weight, chest, waist, biceps, thighs, hips, neck, goal, activity_level
    )
    VALUES (
        p_user_id, p_date, p_height, p_weight, p_chest, p_waist, p_biceps, p_thighs, p_hips, p_neck, p_goal, p_activity_lvl
    );
END;
$$;


ALTER PROCEDURE crud.insert_body_measurement(IN p_user_id integer, IN p_date timestamp without time zone, IN p_height double precision, IN p_weight double precision, IN p_chest double precision, IN p_waist double precision, IN p_biceps double precision, IN p_thighs double precision, IN p_hips double precision, IN p_neck numeric, IN p_goal character varying, IN p_activity_lvl numeric) OWNER TO postgres;

--
-- TOC entry 295 (class 1255 OID 24817)
-- Name: insert_body_measurement(integer, timestamp without time zone, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, text, numeric); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.insert_body_measurement(IN p_user_id integer, IN p_date timestamp without time zone, IN p_height numeric, IN p_weight numeric, IN p_chest numeric, IN p_waist numeric, IN p_biceps numeric, IN p_thighs numeric, IN p_hips numeric, IN p_neck numeric, IN p_goal text, IN p_activity_lvl numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public.body_measurements (
        user_id, date, height, weight, chest, waist, biceps, thighs, hips, neck, goal, activity_level
    )
    VALUES (
        p_user_id, p_date, p_height, p_weight, p_chest, p_waist, p_biceps, p_thighs, p_hips, p_neck, p_goal, p_activity_lvl
    );
END;
$$;


ALTER PROCEDURE crud.insert_body_measurement(IN p_user_id integer, IN p_date timestamp without time zone, IN p_height numeric, IN p_weight numeric, IN p_chest numeric, IN p_waist numeric, IN p_biceps numeric, IN p_thighs numeric, IN p_hips numeric, IN p_neck numeric, IN p_goal text, IN p_activity_lvl numeric) OWNER TO postgres;

--
-- TOC entry 257 (class 1255 OID 24761)
-- Name: insert_exercise(character varying, text, integer); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.insert_exercise(IN p_name character varying, IN p_description text, IN p_muscle_group_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.muscle_groups WHERE id = p_muscle_group_id) THEN
        RAISE EXCEPTION 'Grupa mięśniowa o ID % nie istnieje', p_muscle_group_id;
    END IF;
    INSERT INTO public.exercises (name, description, muscle_group_id) VALUES (p_name, p_description, p_muscle_group_id);
END;
$$;


ALTER PROCEDURE crud.insert_exercise(IN p_name character varying, IN p_description text, IN p_muscle_group_id integer) OWNER TO postgres;

--
-- TOC entry 253 (class 1255 OID 24757)
-- Name: insert_muscle_group(character varying); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.insert_muscle_group(IN p_name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM public.muscle_groups WHERE LOWER(name) = LOWER(p_name)) THEN 
        RAISE EXCEPTION 'Grupa mięśniowa % już istnieje', p_name; 
    END IF;
    INSERT INTO public.muscle_groups (name) VALUES (p_name);
END;
$$;


ALTER PROCEDURE crud.insert_muscle_group(IN p_name character varying) OWNER TO postgres;

--
-- TOC entry 278 (class 1255 OID 24787)
-- Name: insert_user(text, text, text, text, text, text); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.insert_user(IN p_username text, IN p_password text, IN p_email text, IN p_first_name text, IN p_last_name text, IN p_gender text)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    -- 1. Walidacja formatu email (szukana fraza przez PHP: 'format email')
    IF p_email !~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'Niepoprawny format email';
    END IF;

    -- 2. Proba wstawienia danych
    INSERT INTO public.users (username, password, email, first_name, last_name, gender)
    VALUES (p_username, p_password, p_email, p_first_name, p_last_name, p_gender);

EXCEPTION
    -- 3. Obsluga unikalnosci (szukane frazy przez PHP: 'już istnieje' / 'już zajęty')
    WHEN unique_violation THEN
        -- Sprawdzamy, ktory klucz zostal naruszony, aby zwrocic odpowiedni tekst
        IF SQLERRM ~ 'username' THEN
            RAISE EXCEPTION 'Użytkownik o takim loginie już istnieje';
        ELSE
            RAISE EXCEPTION 'Ten adres e-mail jest już zajęty';
        END IF;
END;
$_$;


ALTER PROCEDURE crud.insert_user(IN p_username text, IN p_password text, IN p_email text, IN p_first_name text, IN p_last_name text, IN p_gender text) OWNER TO postgres;

--
-- TOC entry 261 (class 1255 OID 24769)
-- Name: insert_workout(integer, timestamp without time zone); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.insert_workout(IN p_user_id integer, IN p_date timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM public.workouts WHERE user_id = p_user_id AND date = p_date) THEN 
        RAISE EXCEPTION 'Trening dla tego użytkownika o tej samej godzinie już istnieje'; 
    END IF;
    IF EXISTS (SELECT 1 FROM public.workouts WHERE user_id = p_user_id AND date > p_date) THEN
        RAISE EXCEPTION 'Nie można dodać treningu z datą wcześniejszą niż ostatnie wpisy';
    END IF;
    INSERT INTO public.workouts (user_id, date) VALUES (p_user_id, p_date);
END;
$$;


ALTER PROCEDURE crud.insert_workout(IN p_user_id integer, IN p_date timestamp without time zone) OWNER TO postgres;

--
-- TOC entry 276 (class 1255 OID 24821)
-- Name: insert_workout(integer, timestamp without time zone, interval); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.insert_workout(IN p_user_id integer, IN p_date timestamp without time zone, IN p_duration interval)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public.workouts (user_id, date, duration)
    VALUES (p_user_id, p_date, p_duration);
END;
$$;


ALTER PROCEDURE crud.insert_workout(IN p_user_id integer, IN p_date timestamp without time zone, IN p_duration interval) OWNER TO postgres;

--
-- TOC entry 265 (class 1255 OID 24773)
-- Name: insert_workout_exercise(integer, integer); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.insert_workout_exercise(IN p_workout_id integer, IN p_exercise_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.workouts WHERE id = p_workout_id) THEN 
        RAISE EXCEPTION 'Trening o ID % nie istnieje', p_workout_id; 
    END IF;
    IF NOT EXISTS (SELECT 1 FROM public.exercises WHERE id = p_exercise_id) THEN 
        RAISE EXCEPTION 'Ćwiczenie o ID % nie istnieje', p_exercise_id; 
    END IF;
    INSERT INTO public.workout_exercises (workout_id, exercise_id) VALUES (p_workout_id, p_exercise_id);
END;
$$;


ALTER PROCEDURE crud.insert_workout_exercise(IN p_workout_id integer, IN p_exercise_id integer) OWNER TO postgres;

--
-- TOC entry 269 (class 1255 OID 24777)
-- Name: insert_workout_set(integer, double precision, integer, integer); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.insert_workout_set(IN p_workout_exercise_id integer, IN p_weight double precision, IN p_reps integer, IN p_set_number integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_last_set INT;
BEGIN
    IF p_reps <= 0 THEN RAISE EXCEPTION 'Liczba powtórzeń musi być większa od 0'; END IF;
    IF p_weight < 0 THEN RAISE EXCEPTION 'Ciężar nie może być ujemny'; END IF;
    
    SELECT MAX(set_number) INTO v_last_set FROM public.workout_sets WHERE workout_exercise_id = p_workout_exercise_id;
    IF v_last_set IS NOT NULL AND p_set_number != v_last_set + 1 THEN
        RAISE EXCEPTION 'Nieciągłość serii. Ostatnia seria to %, próbujesz dodać %', v_last_set, p_set_number;
    END IF;

    INSERT INTO public.workout_sets (workout_exercise_id, weight, reps, set_number)
    VALUES (p_workout_exercise_id, p_weight, p_reps, p_set_number);
END;
$$;


ALTER PROCEDURE crud.insert_workout_set(IN p_workout_exercise_id integer, IN p_weight double precision, IN p_reps integer, IN p_set_number integer) OWNER TO postgres;

--
-- TOC entry 294 (class 1255 OID 24816)
-- Name: update_body_measurement(integer, integer, timestamp without time zone, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, text, text); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.update_body_measurement(IN p_id integer, IN p_user_id integer, IN p_date timestamp without time zone, IN p_height double precision, IN p_weight double precision, IN p_chest double precision, IN p_waist double precision, IN p_biceps double precision, IN p_thighs double precision, IN p_hips double precision, IN p_neck double precision, IN p_goal text, IN p_activity_lvl text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Sprawdzenie czy pomiar istnieje
    IF NOT EXISTS (SELECT 1 FROM public.body_measurements WHERE id = p_id) THEN 
        RAISE EXCEPTION 'Nie znaleziono pomiaru o ID %', p_id; 
    END IF;

    -- Walidacje (spójne z procedurą insert)
    IF p_height < 50 OR p_height > 250 THEN RAISE EXCEPTION 'Wzrost poza realistycznym zakresem (50-250)'; END IF;
    IF p_weight < 30 OR p_weight > 300 THEN RAISE EXCEPTION 'Waga poza realistycznym zakresem (30-300)'; END IF;
    IF p_chest <= 0 OR p_waist <= 0 OR p_biceps <= 0 OR p_neck <= 0 THEN 
        RAISE EXCEPTION 'Obwody muszą być większe od 0'; 
    END IF;

    -- Aktualizacja rekordu
    UPDATE public.body_measurements SET 
        user_id = p_user_id, 
        date = p_date, 
        height = p_height, 
        weight = p_weight, 
        chest = p_chest, 
        waist = p_waist, 
        biceps = p_biceps, 
        thighs = p_thighs, 
        hips = p_hips,
        neck = p_neck,           -- Nowa kolumna
        goal = p_goal,           -- Nowa kolumna
        activity_lvl = p_activity_lvl -- Nowa kolumna
    WHERE id = p_id;
END;
$$;


ALTER PROCEDURE crud.update_body_measurement(IN p_id integer, IN p_user_id integer, IN p_date timestamp without time zone, IN p_height double precision, IN p_weight double precision, IN p_chest double precision, IN p_waist double precision, IN p_biceps double precision, IN p_thighs double precision, IN p_hips double precision, IN p_neck double precision, IN p_goal text, IN p_activity_lvl text) OWNER TO postgres;

--
-- TOC entry 273 (class 1255 OID 24819)
-- Name: update_body_measurement(integer, integer, timestamp without time zone, double precision, double precision, double precision, double precision, double precision, double precision, double precision, numeric, character varying, numeric); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.update_body_measurement(IN p_id integer, IN p_user_id integer, IN p_date timestamp without time zone, IN p_height double precision, IN p_weight double precision, IN p_chest double precision, IN p_waist double precision, IN p_biceps double precision, IN p_thighs double precision, IN p_hips double precision, IN p_neck numeric, IN p_goal character varying, IN p_activity_lvl numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE public.body_measurements SET 
        user_id = p_user_id, 
        date = p_date, 
        height = p_height, 
        weight = p_weight, 
        chest = p_chest, 
        waist = p_waist, 
        biceps = p_biceps, 
        thighs = p_thighs, 
        hips = p_hips,
        neck = p_neck,
        goal = p_goal,
        activity_level = p_activity_lvl
    WHERE id = p_id;
END;
$$;


ALTER PROCEDURE crud.update_body_measurement(IN p_id integer, IN p_user_id integer, IN p_date timestamp without time zone, IN p_height double precision, IN p_weight double precision, IN p_chest double precision, IN p_waist double precision, IN p_biceps double precision, IN p_thighs double precision, IN p_hips double precision, IN p_neck numeric, IN p_goal character varying, IN p_activity_lvl numeric) OWNER TO postgres;

--
-- TOC entry 258 (class 1255 OID 24762)
-- Name: update_exercise(integer, character varying, text, integer); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.update_exercise(IN p_id integer, IN p_name character varying, IN p_description text, IN p_muscle_group_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.exercises WHERE id = p_id) THEN 
        RAISE EXCEPTION 'Nie znaleziono ćwiczenia o ID %', p_id; 
    END IF;
    IF NOT EXISTS (SELECT 1 FROM public.muscle_groups WHERE id = p_muscle_group_id) THEN
        RAISE EXCEPTION 'Grupa mięśniowa o ID % nie istnieje', p_muscle_group_id;
    END IF;
    UPDATE public.exercises SET name = p_name, description = p_description, muscle_group_id = p_muscle_group_id WHERE id = p_id;
END;
$$;


ALTER PROCEDURE crud.update_exercise(IN p_id integer, IN p_name character varying, IN p_description text, IN p_muscle_group_id integer) OWNER TO postgres;

--
-- TOC entry 254 (class 1255 OID 24758)
-- Name: update_muscle_group(integer, character varying); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.update_muscle_group(IN p_id integer, IN p_name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.muscle_groups WHERE id = p_id) THEN 
        RAISE EXCEPTION 'Nie znaleziono grupy o ID %', p_id; 
    END IF;
    UPDATE public.muscle_groups SET name = p_name WHERE id = p_id;
END;
$$;


ALTER PROCEDURE crud.update_muscle_group(IN p_id integer, IN p_name character varying) OWNER TO postgres;

--
-- TOC entry 292 (class 1255 OID 24814)
-- Name: update_user(integer, text, text, text, text, text, text); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.update_user(IN p_id integer, IN p_username text, IN p_password text, IN p_email text, IN p_first_name text, IN p_last_name text, IN p_gender text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Sprawdzenie czy użytkownik istnieje
    IF NOT EXISTS (SELECT 1 FROM public.users WHERE id = p_id) THEN 
        RAISE EXCEPTION 'Nie znaleziono użytkownika o ID %', p_id; 
    END IF;

    -- Aktualizacja danych wraz z płcią
    UPDATE public.users SET
        username = p_username, 
        password = p_password, 
        email = p_email, 
        first_name = p_first_name, 
        last_name = p_last_name,
        gender = p_gender
    WHERE id = p_id;
END;
$$;


ALTER PROCEDURE crud.update_user(IN p_id integer, IN p_username text, IN p_password text, IN p_email text, IN p_first_name text, IN p_last_name text, IN p_gender text) OWNER TO postgres;

--
-- TOC entry 262 (class 1255 OID 24770)
-- Name: update_workout(integer, integer, timestamp without time zone); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.update_workout(IN p_id integer, IN p_user_id integer, IN p_date timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.workouts WHERE id = p_id) THEN 
        RAISE EXCEPTION 'Nie znaleziono treningu o ID %', p_id; 
    END IF;
    UPDATE public.workouts SET user_id = p_user_id, date = p_date WHERE id = p_id;
END;
$$;


ALTER PROCEDURE crud.update_workout(IN p_id integer, IN p_user_id integer, IN p_date timestamp without time zone) OWNER TO postgres;

--
-- TOC entry 266 (class 1255 OID 24774)
-- Name: update_workout_exercise(integer, integer, integer); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.update_workout_exercise(IN p_id integer, IN p_workout_id integer, IN p_exercise_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.workout_exercises WHERE id = p_id) THEN 
        RAISE EXCEPTION 'Wpis workout_exercise o ID % nie istnieje', p_id; 
    END IF;
    UPDATE public.workout_exercises SET workout_id = p_workout_id, exercise_id = p_exercise_id WHERE id = p_id;
END;
$$;


ALTER PROCEDURE crud.update_workout_exercise(IN p_id integer, IN p_workout_id integer, IN p_exercise_id integer) OWNER TO postgres;

--
-- TOC entry 270 (class 1255 OID 24778)
-- Name: update_workout_set(integer, integer, double precision, integer, integer); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.update_workout_set(IN p_id integer, IN p_workout_exercise_id integer, IN p_weight double precision, IN p_reps integer, IN p_set_number integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.workout_sets WHERE id = p_id) THEN 
        RAISE EXCEPTION 'Seria o ID % nie istnieje', p_id; 
    END IF;
    IF p_reps <= 0 THEN RAISE EXCEPTION 'Liczba powtórzeń musi być większa od 0'; END IF;
    UPDATE public.workout_sets SET 
        workout_exercise_id = p_workout_exercise_id, weight = p_weight, reps = p_reps, set_number = p_set_number 
    WHERE id = p_id;
END;
$$;


ALTER PROCEDURE crud.update_workout_set(IN p_id integer, IN p_workout_exercise_id integer, IN p_weight double precision, IN p_reps integer, IN p_set_number integer) OWNER TO postgres;

--
-- TOC entry 285 (class 1255 OID 24808)
-- Name: calculate_exercise_1rm(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculate_exercise_1rm(p_user_id integer, p_exercise_id integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_weight float;
    v_reps integer;
    v_1rm numeric;
BEGIN
    -- Dodajemy jawne rzutowanie ::int, aby upewnić się, że Postgres znajdzie funkcję
    -- oraz sprawdzamy, czy funkcja na pewno istnieje w Twoim schemacie CRUD
    SELECT h.weight, h.reps 
    INTO v_weight, v_reps
    FROM (
        -- Jeśli funkcja crud nadal sprawia problemy, używamy bezpiecznego podzapytania:
        SELECT ws.weight, ws.reps, w.date as workout_date, ws.set_number
        FROM public.workout_sets ws
        JOIN public.workout_exercises we ON ws.workout_exercise_id = we.id
        JOIN public.workouts w ON we.workout_id = w.id
        WHERE w.user_id = p_user_id::integer 
          AND we.exercise_id = p_exercise_id::integer
    ) h
    WHERE h.set_number = 1
    ORDER BY h.workout_date DESC 
    LIMIT 1;

    IF v_weight IS NULL OR v_reps IS NULL OR v_reps = 0 THEN
        RETURN 0;
    END IF;

    IF v_reps = 1 THEN
        v_1rm := v_weight;
    ELSE
        v_1rm := v_weight / (1.0278 - (0.0278 * v_reps));
    END IF;

    RETURN ROUND((v_1rm * 2)::numeric, 0) / 2;
END;
$$;


ALTER FUNCTION public.calculate_exercise_1rm(p_user_id integer, p_exercise_id integer) OWNER TO postgres;

--
-- TOC entry 282 (class 1255 OID 24788)
-- Name: calculate_user_bf(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculate_user_bf(p_user_id integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_gender TEXT;
    v_height NUMERIC;
    v_waist NUMERIC;
    v_neck NUMERIC;
    v_hips NUMERIC;
    v_bf NUMERIC;
BEGIN
    -- Pobieramy płeć (upewnij się, że w bazie jest dokładnie 'Male' lub 'Female')
    -- Dodajemy TRIM i LOWER dla bezpieczeństwa
    SELECT LOWER(TRIM(gender)) INTO v_gender FROM public.users WHERE id = p_user_id;

    SELECT height, waist, neck, hips INTO v_height, v_waist, v_neck, v_hips
    FROM public.body_measurements
    WHERE user_id = p_user_id
    ORDER BY date DESC LIMIT 1;

    -- Zabezpieczenie przed zerem lub brakiem danych (logarytm z liczby <= 0 wywali błąd)
    IF v_height IS NULL OR v_waist IS NULL OR v_neck IS NULL OR (v_waist - v_neck) <= 0 THEN
        RETURN NULL;
    END IF;

    IF v_gender = 'male' THEN
        -- Wzór US Navy dla mężczyzn
        v_bf := 495 / (1.0324 - 0.19077 * log(v_waist - v_neck) + 0.15456 * log(v_height)) - 450;
    ELSE
        -- Wzór US Navy dla kobiet
        IF v_hips IS NULL OR (v_waist + v_hips - v_neck) <= 0 THEN RETURN NULL; END IF;
        v_bf := 495 / (1.29579 - 0.35004 * log(v_waist + v_hips - v_neck) + 0.22100 * log(v_height)) - 450;
    END IF;

    -- Jeśli wynik wyjdzie absurdalny (np. ujemny), zwróćmy rozsądną granicę
    IF v_bf < 2 THEN RETURN 2.0; END IF;

    RETURN ROUND(v_bf::numeric, 1);
END;
$$;


ALTER FUNCTION public.calculate_user_bf(p_user_id integer) OWNER TO postgres;

--
-- TOC entry 279 (class 1255 OID 24793)
-- Name: calculate_user_diet_calories(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculate_user_diet_calories(p_user_id integer) RETURNS TABLE(recommended_calories integer, goal_label character varying, difference_from_tdee integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_gender varchar;
    v_height float;
    v_weight float;
    v_activity float;
    v_goal varchar;
    v_bmr float;
    v_tdee integer;
    v_age_const integer := 28; -- Przyjęta stała wieku
BEGIN
    -- 1. Pobierz płeć z tabeli users (to tam jest)
    SELECT gender INTO v_gender 
    FROM public.users WHERE id = p_user_id;

    -- 2. Pobierz najnowsze dane fizyczne z pomiarów (waga, WZROST, aktywność, cel)
    SELECT weight, height, activity_level, goal 
    INTO v_weight, v_height, v_activity, v_goal
    FROM public.body_measurements 
    WHERE user_id = p_user_id 
    ORDER BY date DESC LIMIT 1; -- Używamy kolumny 'date' (z Twojego pliku SQL)

    -- Zabezpieczenie przed brakiem danych
    v_weight := COALESCE(v_weight, 70.0);
    v_height := COALESCE(v_height, 175.0);
    v_activity := COALESCE(v_activity, 1.2);
    v_goal := COALESCE(v_goal, 'Rekompozycja ciała');

    -- 3. Oblicz BMR (Mifflin-St Jeor)
    IF lower(v_gender) LIKE 'm%' THEN
        v_bmr := (10 * v_weight) + (6.25 * v_height) - (5 * v_age_const) + 5;
    ELSE
        v_bmr := (10 * v_weight) + (6.25 * v_height) - (5 * v_age_const) - 161;
    END IF;

    -- 4. TDEE
    v_tdee := round(v_bmr * v_activity);

    -- 5. Logika celu
    IF v_goal = 'Zbudowanie masy mięśniowej' THEN
        recommended_calories := round(v_tdee * 1.10);
        goal_label := 'Masa';
    ELSIF v_goal = 'Redukcja tkanki tłuszczowej' THEN
        recommended_calories := round(v_tdee * 0.80);
        goal_label := 'Redukcja';
    ELSE
        recommended_calories := v_tdee;
        goal_label := 'Rekompozycja';
    END IF;

    difference_from_tdee := recommended_calories - v_tdee;

    RETURN NEXT;
END;
$$;


ALTER FUNCTION public.calculate_user_diet_calories(p_user_id integer) OWNER TO postgres;

--
-- TOC entry 286 (class 1255 OID 24810)
-- Name: calculate_workout_total_volume(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculate_workout_total_volume(p_workout_id integer) RETURNS double precision
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_total_volume float;
BEGIN
    -- Sumujemy iloczyn ciężaru i powtórzeń dla wszystkich serii w danym treningu
    SELECT SUM(ws.weight * ws.reps)
    INTO v_total_volume
    FROM public.workout_sets ws
    JOIN public.workout_exercises we ON ws.workout_exercise_id = we.id
    WHERE we.workout_id = p_workout_id;

    -- Jeśli trening nie ma jeszcze serii, zwróć 0 zamiast NULL
    RETURN COALESCE(v_total_volume, 0);
END;
$$;


ALTER FUNCTION public.calculate_workout_total_volume(p_workout_id integer) OWNER TO postgres;

--
-- TOC entry 291 (class 1255 OID 24782)
-- Name: detect_training_split(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.detect_training_split(p_user_id integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_avg_groups_per_workout FLOAT;
    v_days_active_30d INT;
    v_total_groups_30d INT;
    v_has_legs BOOLEAN;
    v_has_push BOOLEAN;
    v_has_pull BOOLEAN;
    v_result TEXT;
BEGIN
    -- 1. Pobieramy statystyki korzystając z funkcji CRUD
    -- Wyliczamy unikalne dni, unikalne grupy oraz flagi kategorii
    SELECT 
        COUNT(DISTINCT s.workout_id),
        COUNT(DISTINCT s.muscle_group_name),
        EXISTS (SELECT 1 FROM crud.get_user_training_stats(p_user_id) x WHERE x.muscle_group_name ILIKE '%Nogi%'),
        EXISTS (SELECT 1 FROM crud.get_user_training_stats(p_user_id) x WHERE x.muscle_group_name IN ('Klatka piersiowa', 'Barki', 'Triceps')),
        EXISTS (SELECT 1 FROM crud.get_user_training_stats(p_user_id) x WHERE x.muscle_group_name IN ('Plecy', 'Biceps'))
    INTO v_days_active_30d, v_total_groups_30d, v_has_legs, v_has_push, v_has_pull
    FROM crud.get_user_training_stats(p_user_id) s;

    -- 2. Średnia grup na trening (również z funkcji CRUD)
    SELECT AVG(daily_count) INTO v_avg_groups_per_workout
    FROM (
        SELECT COUNT(DISTINCT muscle_group_name) as daily_count
        FROM crud.get_user_training_stats(p_user_id)
        GROUP BY workout_id
    ) AS subquery;

    -- Jeśli brak aktywności
    IF v_days_active_30d = 0 OR v_avg_groups_per_workout IS NULL THEN
        RETURN 'Brak aktywności (30 dni)';
    END IF;

    -- 3. Klasyfikacja (Logika bez zmian)
    IF v_avg_groups_per_workout >= 3.8 THEN
        v_result := 'Full Body Workout';
    ELSIF v_has_push AND v_has_pull AND NOT v_has_legs THEN
        v_result := 'Push Pull (No Legs)';
    ELSIF v_has_push AND v_has_pull AND v_has_legs AND v_avg_groups_per_workout < 3.5 THEN
        v_result := 'Push Pull Legs';
    ELSIF v_has_legs AND v_days_active_30d >= 4 AND v_total_groups_30d >= 5 AND v_avg_groups_per_workout BETWEEN 2.5 AND 3.5 THEN
        v_result := 'Upper Lower';
    ELSIF v_days_active_30d >= 4 AND v_avg_groups_per_workout < 2.5 THEN
        v_result := 'Body Part Split';
    ELSE
        v_result := 'Własny system';
    END IF;

    RETURN v_result;
END;
$$;


ALTER FUNCTION public.detect_training_split(p_user_id integer) OWNER TO postgres;

--
-- TOC entry 238 (class 1255 OID 16517)
-- Name: get_detailed_workout(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_detailed_workout(p_user_id integer, p_workout_id integer) RETURNS TABLE(workout_id integer, workout_date timestamp without time zone, exercise_name character varying, set_number integer, weight double precision, reps integer)
    LANGUAGE sql
    AS $$
    SELECT
        w.id AS workout_id,
        w.date AS workout_date,
        e.name AS exercise_name,
        ws.set_number,
        ws.weight,
        ws.reps
    FROM 
        workouts w
    JOIN 
        workout_exercises we ON w.id = we.workout_id
    JOIN
        exercises e ON we.exercise_id = e.id
    JOIN 
        workout_sets ws ON we.id = ws.workout_exercise_id
    WHERE
        w.id = p_workout_id
        AND w.user_id = p_user_id -- Zabezpieczenie: upewnij się, że trening należy do tego użytkownika
    ORDER BY
        w.date, e.name, ws.set_number;
$$;


ALTER FUNCTION public.get_detailed_workout(p_user_id integer, p_workout_id integer) OWNER TO postgres;

--
-- TOC entry 287 (class 1255 OID 24809)
-- Name: get_exercise_progression_status(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_exercise_progression_status(p_user_id integer, p_exercise_id integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_last_total_vol float;
    v_prev_total_vol float;
    v_entry_count integer;
BEGIN
    -- 1. Pobieramy objętości z dwóch ostatnich sesji, w których wystąpiło to ćwiczenie
    -- Używamy DISTINCT workout_id, żeby mieć pewność, że to dwa osobne treningi
    WITH exercise_history AS (
        SELECT 
            w.id as workout_id,
            w.date,
            SUM(ws.weight * ws.reps) as total_volume
        FROM public.workout_sets ws
        JOIN public.workout_exercises we ON ws.workout_exercise_id = we.id
        JOIN public.workouts w ON we.workout_id = w.id
        WHERE w.user_id = p_user_id 
          AND we.exercise_id = p_exercise_id
        GROUP BY w.id, w.date
        ORDER BY w.date DESC
        LIMIT 2
    ),
    ranked_history AS (
        SELECT 
            total_volume, 
            ROW_NUMBER() OVER (ORDER BY date DESC) as rn
        FROM exercise_history
    )
    SELECT 
        MAX(CASE WHEN rn = 1 THEN total_volume END),
        MAX(CASE WHEN rn = 2 THEN total_volume END),
        (SELECT COUNT(*) FROM exercise_history)
    INTO v_last_total_vol, v_prev_total_vol, v_entry_count
    FROM ranked_history;

    -- 2. Debug: Jeśli masz mniej niż 2 sesje w historii, to zawsze będzie NEW
    IF v_entry_count < 2 THEN 
        RETURN 'NEW'; 
    END IF;

    -- 3. Porównanie objętości
    IF v_last_total_vol > v_prev_total_vol THEN
        RETURN 'PROGRESS';     
    ELSIF v_last_total_vol = v_prev_total_vol THEN
        RETURN 'STAGNATION';   
    ELSE
        RETURN 'REGRESSION';   
    END IF;
END;
$$;


ALTER FUNCTION public.get_exercise_progression_status(p_user_id integer, p_exercise_id integer) OWNER TO postgres;

--
-- TOC entry 274 (class 1255 OID 24783)
-- Name: get_exercise_volume_progression(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_exercise_volume_progression(p_user_id integer, p_exercise_id integer) RETURNS TABLE(workout_date date, total_volume numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        w.date::DATE,
        -- Obliczamy objętość: suma (ciężar * powtórzenia) dla wszystkich serii w danym dniu
        SUM(COALESCE(ws.weight, 0) * COALESCE(ws.reps, 0))::NUMERIC
    FROM public.workouts w
    -- Łączymy trening z ćwiczeniami (tabela pośrednia w Twojej bazie)
    JOIN public.workout_exercises we ON w.id = we.workout_id
    -- Łączymy z seriami (workout_sets łączy się z workout_exercises przez workout_exercise_id)
    JOIN public.workout_sets ws ON we.id = ws.workout_exercise_id
    WHERE w.user_id = p_user_id 
      AND we.exercise_id = p_exercise_id
      AND w.date >= CURRENT_DATE - INTERVAL '3 months'
    GROUP BY w.date::DATE
    ORDER BY w.date::DATE ASC;
END;
$$;


ALTER FUNCTION public.get_exercise_volume_progression(p_user_id integer, p_exercise_id integer) OWNER TO postgres;

--
-- TOC entry 250 (class 1255 OID 16516)
-- Name: get_exercises_by_muscle_group(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_exercises_by_muscle_group(p_muscle_group_name character varying) RETURNS TABLE(exercise_id integer, exercise_name character varying, muscle_group_name character varying)
    LANGUAGE sql
    AS $$
    SELECT 
        e.id, 
        e.name, 
        mg.name
    FROM 
        exercises e
    JOIN 
        muscle_groups mg ON e.muscle_group_id = mg.id
    WHERE
        mg.name ILIKE p_muscle_group_name -- Wyszukiwanie bez względu na wielkość liter (ILIKE)
    ORDER BY
        e.name;
$$;


ALTER FUNCTION public.get_exercises_by_muscle_group(p_muscle_group_name character varying) OWNER TO postgres;

--
-- TOC entry 284 (class 1255 OID 24807)
-- Name: get_last_exercise_stats(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_last_exercise_stats(p_user_id integer, p_exercise_id integer, p_set_no integer) RETURNS TABLE(last_weight double precision, last_reps integer)
    LANGUAGE sql
    AS $$
    SELECT ws.weight, ws.reps
    FROM workout_sets ws
    JOIN workout_exercises we ON ws.workout_exercise_id = we.id
    JOIN workouts w ON we.workout_id = w.id
    WHERE w.user_id = p_user_id 
      AND we.exercise_id = p_exercise_id
      AND ws.set_number = p_set_no -- Szukamy konkretnego numeru serii
    ORDER BY w.date DESC
    LIMIT 1;
$$;


ALTER FUNCTION public.get_last_exercise_stats(p_user_id integer, p_exercise_id integer, p_set_no integer) OWNER TO postgres;

--
-- TOC entry 277 (class 1255 OID 24794)
-- Name: get_user_macros(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_user_macros(p_user_id integer) RETURNS TABLE(protein_g integer, fat_g integer, carbs_g integer, calories_total integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_weight float;
    v_kcal integer;
BEGIN
    -- 1. Pobierz kalorie z Twojego głównego algorytmu
    SELECT recommended_calories INTO v_kcal 
    FROM public.calculate_user_diet_calories(p_user_id);

    -- 2. Pobierz najnowszą wagę
    SELECT weight INTO v_weight 
    FROM public.body_measurements 
    WHERE user_id = p_user_id 
    ORDER BY date DESC LIMIT 1;

    -- Domyślna waga jeśli brak pomiaru
    v_weight := COALESCE(v_weight, 70.0);
    calories_total := v_kcal;

    -- 3. OBLICZENIA
    -- Białko: 2g na kg masy ciała
    protein_g := round(v_weight * 2.0);
    
    -- Tłuszcze: 25% kalorii (1g tłuszczu = 9 kcal)
    fat_g := round((v_kcal * 0.25) / 9);
    
    -- Węglowodany: Reszta (1g węgli = 4 kcal)
    carbs_g := round((v_kcal - (protein_g * 4) - (fat_g * 9)) / 4);

    RETURN NEXT;
END;
$$;


ALTER FUNCTION public.get_user_macros(p_user_id integer) OWNER TO postgres;

--
-- TOC entry 296 (class 1255 OID 24822)
-- Name: get_user_measurements(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_user_measurements(p_user_id integer) RETURNS TABLE(measurement_id integer, date timestamp without time zone, height double precision, weight double precision, chest double precision, waist double precision, neck double precision, biceps double precision, thighs double precision, hips double precision)
    LANGUAGE sql
    AS $$
    SELECT 
        bm.id,
        bm.date,
        bm.height,
        bm.weight,
        bm.chest,
        bm.waist,
        bm.neck, -- Nowa kolumna
        bm.biceps,
        bm.thighs,
        bm.hips
    FROM 
        public.body_measurements bm
    WHERE 
        bm.user_id = p_user_id
    ORDER BY
        bm.date ASC;
$$;


ALTER FUNCTION public.get_user_measurements(p_user_id integer) OWNER TO postgres;

--
-- TOC entry 288 (class 1255 OID 24811)
-- Name: get_user_muscle_balance(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_user_muscle_balance(p_user_id integer) RETURNS TABLE(muscle_group_name text, volume_percentage numeric)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_total_volume numeric;
BEGIN
    -- 1. Obliczamy całkowitą objętość (rzutujemy na numeric dla bezpieczeństwa)
    SELECT SUM(ws.weight * ws.reps)::numeric INTO v_total_volume
    FROM public.workout_sets ws
    JOIN public.workout_exercises we ON ws.workout_exercise_id = we.id
    JOIN public.workouts w ON we.workout_id = w.id
    WHERE w.user_id = p_user_id AND w.date > NOW() - INTERVAL '7 days';

    -- Jeśli brak treningów, zwracamy pustą tabelę
    IF v_total_volume IS NULL OR v_total_volume = 0 THEN
        RETURN;
    END IF;

    -- 2. Zwracamy procentowy udział (dodano rzutowanie przed ROUND)
    RETURN QUERY
    SELECT 
        mg.name::text,
        ROUND(((SUM(ws.weight * ws.reps) / v_total_volume) * 100)::numeric, 1) as percentage
    FROM public.workout_sets ws
    JOIN public.workout_exercises we ON ws.workout_exercise_id = we.id
    JOIN public.workouts w ON we.workout_id = w.id
    JOIN public.exercises e ON we.exercise_id = e.id
    JOIN public.muscle_groups mg ON e.muscle_group_id = mg.id
    WHERE w.user_id = p_user_id AND w.date > NOW() - INTERVAL '7 days'
    GROUP BY mg.name
    ORDER BY percentage DESC;
END;
$$;


ALTER FUNCTION public.get_user_muscle_balance(p_user_id integer) OWNER TO postgres;

--
-- TOC entry 283 (class 1255 OID 24806)
-- Name: get_user_workout_history(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_user_workout_history(p_user_id integer) RETURNS TABLE(workout_id integer, user_workout_no bigint, workout_date timestamp without time zone, duration interval, exercise_name character varying, set_number integer, weight double precision, reps integer)
    LANGUAGE sql
    AS $$
    SELECT
        w.id AS workout_id,
        -- Numerowanie treningów od 1 dla każdego użytkownika z osobna
        DENSE_RANK() OVER (PARTITION BY w.user_id ORDER BY w.date ASC) AS user_workout_no,
        w.date AS workout_date,
        w.duration,
        e.name AS exercise_name,
        ws.set_number,
        ws.weight,
        ws.reps
    FROM 
        workouts w
    JOIN 
        workout_exercises we ON w.id = we.workout_id
    JOIN
        exercises e ON we.exercise_id = e.id
    JOIN 
        workout_sets ws ON we.id = ws.workout_exercise_id
    WHERE
        w.user_id = p_user_id
    ORDER BY
        w.date DESC, we.id ASC, ws.set_number ASC;
$$;


ALTER FUNCTION public.get_user_workout_history(p_user_id integer) OWNER TO postgres;

--
-- TOC entry 289 (class 1255 OID 24812)
-- Name: get_volume_comparison(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_volume_comparison(p_user_id integer) RETURNS TABLE(current_volume numeric, previous_volume numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        -- Tonaż z ostatnich 7 dni
        COALESCE((SELECT SUM(ws.weight * ws.reps)::numeric 
         FROM public.workout_sets ws
         JOIN public.workout_exercises we ON ws.workout_exercise_id = we.id
         JOIN public.workouts w ON we.workout_id = w.id
         WHERE w.user_id = p_user_id AND w.date > NOW() - INTERVAL '7 days'), 0),
        
        -- Tonaż z dni 8-14
        COALESCE((SELECT SUM(ws.weight * ws.reps)::numeric 
         FROM public.workout_sets ws
         JOIN public.workout_exercises we ON ws.workout_exercise_id = we.id
         JOIN public.workouts w ON we.workout_id = w.id
         WHERE w.user_id = p_user_id AND w.date <= NOW() - INTERVAL '7 days' 
         AND w.date > NOW() - INTERVAL '14 days'), 0);
END;
$$;


ALTER FUNCTION public.get_volume_comparison(p_user_id integer) OWNER TO postgres;

--
-- TOC entry 234 (class 1255 OID 16506)
-- Name: login_by_username(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.login_by_username(p_username character varying, p_password character varying) RETURNS TABLE(user_id integer, first_name character varying)
    LANGUAGE sql
    AS $$
    SELECT u.id, u.first_name
    FROM users u
    WHERE u.username = p_username
      AND u.password = p_password;
$$;


ALTER FUNCTION public.login_by_username(p_username character varying, p_password character varying) OWNER TO postgres;

--
-- TOC entry 281 (class 1255 OID 24804)
-- Name: save_complete_workout(integer, integer, jsonb); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.save_complete_workout(p_user_id integer, p_duration_sec integer, p_workout_data jsonb) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_workout_id INTEGER;
    v_workout_exercise_id INTEGER;
    v_exercise RECORD;
    v_set RECORD;
    v_set_idx INTEGER;
    v_now TIMESTAMP := CURRENT_TIMESTAMP;
    v_duration INTERVAL := (p_duration_sec || ' seconds')::INTERVAL; -- Przygotowanie interwału
BEGIN
    -- 1. CZYSTY CRUD: Wstawiamy nagłówek od razu z czasem trwania
    CALL crud.insert_workout(p_user_id, v_now, v_duration);
    
    -- Pobieramy ID stworzonego treningu
    SELECT id INTO v_workout_id 
    FROM public.workouts 
    WHERE user_id = p_user_id 
    ORDER BY date DESC, id DESC LIMIT 1;

    -- 2. Pętla po ćwiczeniach (Wykorzystuje CALL crud.insert_workout_exercise)
    FOR v_exercise IN SELECT * FROM jsonb_array_elements(p_workout_data)
    LOOP
        CALL crud.insert_workout_exercise(v_workout_id, (v_exercise.value->>'exercise_id')::INTEGER);
        
        SELECT id INTO v_workout_exercise_id 
        FROM public.workout_exercises 
        WHERE workout_id = v_workout_id 
        AND exercise_id = (v_exercise.value->>'exercise_id')::INTEGER
        ORDER BY id DESC LIMIT 1;

        -- 3. Pętla po seriach (Wykorzystuje CALL crud.insert_workout_set)
        v_set_idx := 1;
        FOR v_set IN SELECT * FROM jsonb_array_elements(v_exercise.value->'sets')
        LOOP
            CALL crud.insert_workout_set(
                v_workout_exercise_id,
                (v_set.value->>'weight')::DOUBLE PRECISION,
                (v_set.value->>'reps')::INTEGER,
                v_set_idx
            );
            v_set_idx := v_set_idx + 1;
        END LOOP;
    END LOOP;

    RETURN v_workout_id;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Błąd podczas zapisu treningu (Integracja CRUD): %', SQLERRM;
END;
$$;


ALTER FUNCTION public.save_complete_workout(p_user_id integer, p_duration_sec integer, p_workout_data jsonb) OWNER TO postgres;

--
-- TOC entry 280 (class 1255 OID 24803)
-- Name: update_user_measurements(integer, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.update_user_measurements(IN p_user_id integer, IN p_weight numeric, IN p_height numeric, IN p_neck numeric, IN p_waist numeric, IN p_chest numeric, IN p_biceps numeric, IN p_thighs numeric, IN p_hips numeric, IN p_activity_level numeric, IN p_goal character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Wstawiamy nowy rekord pomiarów
    INSERT INTO public.body_measurements (
        user_id, weight, height, neck, waist, 
        chest, biceps, thighs, hips, 
        activity_level, goal, date
    ) VALUES (
        p_user_id, p_weight, p_height, p_neck, p_waist, 
        p_chest, p_biceps, p_thighs, p_hips, 
        p_activity_level, p_goal, CURRENT_DATE
    );

    -- Tutaj w przyszłości możesz dodać np. logikę powiadomień 
    -- lub automatyczne czyszczenie starych rekordów.
END;
$$;


ALTER PROCEDURE public.update_user_measurements(IN p_user_id integer, IN p_weight numeric, IN p_height numeric, IN p_neck numeric, IN p_waist numeric, IN p_chest numeric, IN p_biceps numeric, IN p_thighs numeric, IN p_hips numeric, IN p_activity_level numeric, IN p_goal character varying) OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 16430)
-- Name: body_measurements_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.body_measurements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.body_measurements_id_seq OWNER TO postgres;

--
-- TOC entry 5138 (class 0 OID 0)
-- Dependencies: 226
-- Name: body_measurements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.body_measurements_id_seq OWNED BY public.body_measurements.id;


--
-- TOC entry 224 (class 1259 OID 16413)
-- Name: exercises_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.exercises_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.exercises_id_seq OWNER TO postgres;

--
-- TOC entry 5139 (class 0 OID 0)
-- Dependencies: 224
-- Name: exercises_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.exercises_id_seq OWNED BY public.exercises.id;


--
-- TOC entry 222 (class 1259 OID 16404)
-- Name: muscle_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.muscle_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.muscle_groups_id_seq OWNER TO postgres;

--
-- TOC entry 5140 (class 0 OID 0)
-- Dependencies: 222
-- Name: muscle_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.muscle_groups_id_seq OWNED BY public.muscle_groups.id;


--
-- TOC entry 220 (class 1259 OID 16389)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- TOC entry 5141 (class 0 OID 0)
-- Dependencies: 220
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 230 (class 1259 OID 16460)
-- Name: workout_exercises_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.workout_exercises_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.workout_exercises_id_seq OWNER TO postgres;

--
-- TOC entry 5142 (class 0 OID 0)
-- Dependencies: 230
-- Name: workout_exercises_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.workout_exercises_id_seq OWNED BY public.workout_exercises.id;


--
-- TOC entry 232 (class 1259 OID 16480)
-- Name: workout_sets_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.workout_sets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.workout_sets_id_seq OWNER TO postgres;

--
-- TOC entry 5143 (class 0 OID 0)
-- Dependencies: 232
-- Name: workout_sets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.workout_sets_id_seq OWNED BY public.workout_sets.id;


--
-- TOC entry 228 (class 1259 OID 16445)
-- Name: workouts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.workouts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.workouts_id_seq OWNER TO postgres;

--
-- TOC entry 5144 (class 0 OID 0)
-- Dependencies: 228
-- Name: workouts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.workouts_id_seq OWNED BY public.workouts.id;


--
-- TOC entry 4942 (class 2604 OID 16434)
-- Name: body_measurements id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.body_measurements ALTER COLUMN id SET DEFAULT nextval('public.body_measurements_id_seq'::regclass);


--
-- TOC entry 4941 (class 2604 OID 16417)
-- Name: exercises id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exercises ALTER COLUMN id SET DEFAULT nextval('public.exercises_id_seq'::regclass);


--
-- TOC entry 4940 (class 2604 OID 16408)
-- Name: muscle_groups id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.muscle_groups ALTER COLUMN id SET DEFAULT nextval('public.muscle_groups_id_seq'::regclass);


--
-- TOC entry 4939 (class 2604 OID 16393)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 4946 (class 2604 OID 16464)
-- Name: workout_exercises id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workout_exercises ALTER COLUMN id SET DEFAULT nextval('public.workout_exercises_id_seq'::regclass);


--
-- TOC entry 4947 (class 2604 OID 16484)
-- Name: workout_sets id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workout_sets ALTER COLUMN id SET DEFAULT nextval('public.workout_sets_id_seq'::regclass);


--
-- TOC entry 4945 (class 2604 OID 16449)
-- Name: workouts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workouts ALTER COLUMN id SET DEFAULT nextval('public.workouts_id_seq'::regclass);


--
-- TOC entry 5123 (class 0 OID 16431)
-- Dependencies: 227
-- Data for Name: body_measurements; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.body_measurements (id, user_id, date, height, weight, chest, waist, biceps, thighs, hips, neck, goal, activity_level) FROM stdin;
1	1	2025-11-26 16:52:38.017785	180	85.5	105	90	38	60	100	\N	Rekompozycja	1.200
2	2	2025-11-26 16:52:38.017785	165	58	88	65	28	52	92	\N	Rekompozycja	1.200
3	3	2025-11-26 16:52:38.017785	178	92	110	95	41	65	102	\N	Rekompozycja	1.200
4	4	2025-11-26 16:52:38.017785	170	62.5	90	68	29	55	95	\N	Rekompozycja	1.200
5	5	2025-11-26 16:52:38.017785	185	78	100	82	36	58	98	\N	Rekompozycja	1.200
6	1	2025-12-29 00:00:00	180	85	\N	90	\N	\N	95	40	Rekompozycja	1.200
7	15	2025-12-29 00:00:00	175	83	107	87	40	58	99	38	Rekompozycja	1.200
8	15	2026-01-02 00:00:00	175	82	108	86	40	57	98	38	Zbudowanie masy mięśniowej	1.550
9	15	2026-01-02 00:00:00	175	83	108	86	40	57	98	38	Rekompozycja ciała	1.200
10	15	2026-01-02 00:00:00	175	84	107	87	40	58	99	38	Rekompozycja ciała	1.550
11	7	2026-01-02 00:00:00	180	80	110	90	38	70	100	39	Rekompozycja ciała	1.550
12	14	2026-01-02 00:00:00	180	80	102	90	35	60	99	38	Rekompozycja ciała	1.550
13	15	2026-01-05 00:00:00	175	83	106	87	39.5	58	99	38	Rekompozycja ciała	1.550
14	16	2026-01-05 00:00:00	175	83	106	87	39.5	58	99	38	Rekompozycja ciała	1.550
15	15	2026-01-12 00:00:00	175	83	107	87	40	58	98	38	Rekompozycja ciała	1.550
16	7	2026-01-12 18:18:25.525567	175	85	115	97	41	75	105	40	Rekompozycja ciała	1.375
17	7	2026-01-12 18:18:39.640698	175	85	115	97	41	75	105	40	Rekompozycja ciała	1.375
\.


--
-- TOC entry 5121 (class 0 OID 16414)
-- Dependencies: 225
-- Data for Name: exercises; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.exercises (id, name, description, muscle_group_id) FROM stdin;
1	Pompki klasyczne	\N	1
2	Rozpiętki na maszynie	\N	1
3	Rozpiętki z hantlami na ławce płaskiej	\N	1
4	Rozpiętki z hantlami na ławce skośnej	\N	1
5	Rozpiętki z linkami na bramie	\N	1
6	Wyciskanie sztangi na ławce płaskiej	\N	1
7	Wyciskanie sztangi na ławce skośnej	\N	1
8	Wyciskanie sztangi na maszynie Smith na ławce płaskiej	\N	1
9	Wyciskanie sztangi na maszynie Smith na ławce skośnej	\N	1
10	Wyciskanie hantli na ławce płaskiej	\N	1
11	Wyciskanie hantli na ławce skośnej	\N	1
12	Wyciskanie na maszynie hammer	\N	1
13	Podciąganie chwytem neutralny	\N	2
14	Podciąganie nachwytem	\N	2
15	Podciąganie podchwytem	\N	2
16	Ściąganie drążka wyciągu górnego do klatki	\N	2
17	Ściąganie drążka wyciągu górnego prostymi rękami	\N	2
18	Wiosłowanie sztangą	\N	2
19	Wiosłowanie hantlą jednorącz	\N	2
20	Wiosłowanie hantlami	\N	2
21	Wiosłowanie na maszynie	\N	2
22	Wiosłowanie linką wyciągu	\N	2
23	Ściąganie linki wyciągu górnego jednorącz	\N	2
24	Wiosłowanie z linką wyciągu dolnego	\N	2
25	Wiosłowanie T-bar	\N	2
26	Facepull	\N	3
27	Odwrotne rozpiętki na maszynie	\N	3
28	Wyciskanie żołnierskie z przed głowy	\N	3
29	Wznosy bokiem z hantlami	\N	3
30	Wznosy bokiem z linką wyciągu	\N	3
31	Unoszenie ramion w bok na maszynie	\N	3
32	Wznosy bokiem z hantlami w opadzie tułowia	\N	3
33	Wznosy bokiem z linką wyciągu w opadzie	\N	3
34	Wyciskanie hantli nad głowę	\N	3
35	Wyciskanie na maszynie Smitha	\N	3
36	Pompki na poręczach	\N	4
37	Prostowanie ramion na wyciągu górnym	\N	4
38	Prostowanie ramion z za głowy	\N	4
39	Prostowanie ramion na maszynie	\N	4
40	Wyciskanie francuskie hantlami	\N	4
41	Wyciskanie francuskie sztangą	\N	4
42	Młotkowe uginanie ramion z hantlami	\N	5
43	Uginanie ramion z hantlami stojąc	\N	5
44	Uginanie ramion z hantlami siedząc	\N	5
45	Uginanie ramion na maszynie	\N	5
46	Uginanie ramion ze sztangą	\N	5
47	Uginanie ramion z hantlami na modlitewniku	\N	5
48	Uginanie ramion z hantlą w podporze o kolano	\N	5
49	Uginanie ramion na wyciągu dolnym	\N	5
53	Kickback na wyciągu	\N	6
54	Hip thrust ze sztangą	\N	6
55	Hip thrust na maszynie	\N	6
56	Hip thrust jednonóż	\N	6
57	Martwy ciąg na prostych nogach ze sztangą	\N	6
58	Martwy ciąg na prostych nogach jednonóż z hantlą	\N	6
59	Martwy ciąg klasyczny	\N	6
60	Martwy ciąg sumo	\N	6
61	Nordic hamstring curl	\N	6
62	Odwodzenie nóg na maszynie	\N	6
63	Odwodzenie nogi w bok ma lince wyciągu	\N	6
64	Prostowanie nóg na maszynie	\N	6
65	Prostowanie nóg na suwnicy	\N	6
66	Przysiad bułgarski z hantlami	\N	6
67	Przysiad bułgarski ze sztangą	\N	6
68	Przysiad na maszynie Smith	\N	6
69	Przysiad klasyczny ze sztangą	\N	6
70	Goblet Squat	\N	6
71	Przywodzenie nóg na maszynie	\N	6
72	Skłony ze sztangą	\N	6
73	Wchodzenie na skrzynię z obciążeniem	\N	6
74	Wykroki z hantlami	\N	6
75	Zakroki z hantlami	\N	6
76	Wykroki ze sztangą	\N	6
77	Zakroki ze sztangą	\N	6
78	Przysiad na maszynie	\N	6
79	Zginanie podudzi na maszynie	\N	6
80	Brzuszki	\N	7
81	Brzuszki (kolano do łokcia)	\N	7
82	Ćwiczenie z wykorzystaniem kółka	\N	7
83	Deska	\N	7
84	Hollow Body	\N	7
85	Wspinaczka	\N	7
86	Nożyce	\N	7
87	Allahy na wyciągu górnym	\N	7
88	Deska bokiem	\N	7
89	Russian twist	\N	7
90	Skłony bokiem z hantlą stojąc	\N	7
91	Skłony bokiem z linką wyciągu	\N	7
92	Przyciąganie kolan do klatki siedząc	\N	7
93	Przyciąganie kolan do klatki na maszynie	\N	7
94	Unoszenie nóg na maszynie	\N	7
95	Unoszenie nóg na drążku	\N	7
96	Unoszenie nóg leżąc	\N	7
97	Spięcia brzucha na maszynie	\N	7
98	Wznosy nóg na poręczach	\N	7
99	Wspięcia na palce na maszynie Smith	\N	8
100	Wspięcia na palce na suwnicy	\N	8
101	Wspięcia na palce z hantlem siedząc	\N	8
102	Wypychanie palcami na maszynie	\N	8
103	Wspięcia na palce na stopniu	\N	8
\.


--
-- TOC entry 5119 (class 0 OID 16405)
-- Dependencies: 223
-- Data for Name: muscle_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.muscle_groups (id, name) FROM stdin;
1	Klatka piersiowa
2	Plecy
3	Barki
4	Triceps
5	Biceps
6	Uda i pośladki
7	Brzuch
8	Łydki
\.


--
-- TOC entry 5117 (class 0 OID 16390)
-- Dependencies: 221
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, username, password, email, first_name, last_name, gender) FROM stdin;
14	mark	gryz	marcin@gmail.com	Marcin	Fryz	Male
15	oleiy	ylo	oleiy@gmail.com	Oliwier	Hędrzak	Male
3	piotr_wisniewski	silownia2023	piotr.w@example.com	Piotr	Wiśniewski	Male
5	michal_zielinski	trening1	michal.z@example.com	Michał	Zieliński	Male
6	nowy_user	nowe_haslo	nowy@user.com	Test	Testowy	Male
7	test	test	test@example.com	Test	Test	Male
8	trener_arek	haslo123	arek@gym.pl	Arkadiusz	Nowak	Male
1	jan_kowalski	haslo123	jan.k@example.com	Jan	Kowalski	Male
2	anna_nowak	bezpieczneHaslo	anna.n@example.com	Anna	Nowak	Female
4	kasia_lewandowska	fitness4life	kasia.l@example.com	Katarzyna	Lewandowska	Female
16	oh134913	134913	oh134913@stud.ur.edu.pl	Oliwier	Hędrzak	Male
17	dam	dam	dam@type.pl	Damian	Dudek	Male
18	jan_mar	jan	janmar@onet.pl	Jan	Markowski	Male
\.


--
-- TOC entry 5127 (class 0 OID 16461)
-- Dependencies: 231
-- Data for Name: workout_exercises; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.workout_exercises (id, workout_id, exercise_id) FROM stdin;
1	1	6
2	1	34
3	1	29
4	1	37
5	2	11
6	2	29
7	2	37
8	2	6
9	3	6
10	3	34
11	3	29
12	3	37
13	3	11
14	4	18
15	4	16
16	4	19
17	4	46
18	5	16
19	5	19
20	5	46
21	6	18
22	6	16
23	6	19
24	6	46
25	7	69
26	7	54
27	7	87
28	7	59
29	8	59
30	8	54
31	8	87
32	8	69
33	9	69
34	9	59
35	9	54
36	9	87
37	10	6
38	10	34
39	10	29
40	10	37
41	11	11
42	11	29
43	11	37
44	11	6
45	12	6
46	12	34
47	12	29
48	12	37
49	12	11
50	13	18
51	13	16
52	13	19
53	13	46
54	14	16
55	14	19
56	14	46
57	15	18
58	15	16
59	15	19
60	15	46
61	16	69
62	16	54
63	16	87
64	16	59
65	17	59
66	17	54
67	17	87
68	17	69
69	18	69
70	18	59
71	18	54
72	18	87
73	19	6
74	19	34
75	19	29
76	19	37
77	20	11
78	20	29
79	20	37
80	20	6
81	21	6
82	21	34
83	21	29
84	21	37
85	21	11
86	22	18
87	22	16
88	22	19
89	22	46
90	23	16
91	23	19
92	23	46
93	24	18
94	24	16
95	24	19
96	24	46
97	25	11
98	25	16
99	25	69
100	25	37
101	25	46
102	25	87
103	26	6
104	26	18
105	26	59
106	26	34
107	26	46
108	27	11
109	27	16
110	27	69
111	27	37
112	27	46
113	27	87
114	28	6
115	28	18
116	28	59
117	28	34
118	28	46
119	29	11
120	29	16
121	29	69
122	29	37
123	29	46
124	29	87
125	30	6
126	30	18
127	30	59
128	30	34
129	30	46
130	31	11
131	31	16
132	31	69
133	31	37
134	31	46
135	31	87
136	32	6
137	32	18
138	32	59
139	32	34
140	32	46
141	33	11
142	33	16
143	33	69
144	33	37
145	33	46
146	33	87
147	34	6
148	34	18
149	34	59
150	34	34
151	34	46
152	35	11
153	35	16
154	35	69
155	35	37
156	35	46
157	35	87
158	36	6
159	36	18
160	36	59
161	36	34
162	36	46
165	39	1
166	39	2
167	40	4
168	40	5
169	41	1
170	41	2
171	42	4
172	42	5
173	43	1
174	43	2
175	44	4
176	44	5
177	45	1
178	45	2
179	46	4
180	46	5
181	47	1
182	47	2
183	48	4
184	48	5
185	49	1
186	49	2
187	50	4
188	50	5
189	51	1
190	51	2
191	52	4
192	52	5
193	53	1
194	53	2
195	54	4
196	54	5
197	55	1
198	55	2
199	56	4
200	56	5
201	57	1
202	57	2
203	58	4
204	58	5
205	59	1
206	59	2
207	60	4
208	60	5
209	61	1
210	61	2
211	62	4
212	62	5
214	64	6
215	64	34
216	65	14
217	65	19
218	66	69
219	67	46
220	68	6
221	69	6
222	70	6
223	71	6
224	72	6
225	73	6
226	74	6
227	75	6
228	76	6
229	77	12
230	77	20
231	78	11
232	78	21
233	78	29
234	79	6
235	80	16
236	80	19
237	80	17
238	80	45
239	81	12
240	81	34
241	81	5
242	81	40
243	82	12
244	82	34
245	82	2
246	82	30
247	82	37
248	83	12
249	83	34
250	83	2
251	83	30
252	83	38
253	84	13
254	84	21
255	84	17
256	84	45
257	84	27
258	84	42
259	85	12
260	85	34
261	85	2
262	85	30
263	85	37
264	86	16
265	86	19
266	86	17
267	86	45
268	86	27
269	87	6
270	87	34
271	87	2
272	87	31
273	87	37
274	88	13
275	88	21
276	88	17
277	88	44
278	88	27
279	89	12
280	89	34
281	89	5
282	89	30
283	89	37
284	90	13
285	90	21
286	90	45
287	90	27
288	91	6
289	91	59
290	91	69
291	92	6
292	92	34
293	93	2
294	94	12
\.


--
-- TOC entry 5129 (class 0 OID 16481)
-- Dependencies: 233
-- Data for Name: workout_sets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.workout_sets (id, workout_exercise_id, weight, reps, set_number) FROM stdin;
1	1	80	9	1
2	1	80	9	2
3	1	80	9	3
4	1	80	9	4
5	2	80	8	1
6	2	80	8	2
7	2	80	8	3
8	3	80	10	1
9	3	80	10	2
10	3	80	10	3
11	4	80	11	1
12	4	80	11	2
13	4	80	11	3
14	4	80	11	4
15	5	15	10	1
16	5	15	10	2
17	5	15	10	3
18	6	15	13	1
19	6	15	13	2
20	6	15	13	3
21	7	15	12	1
22	7	15	12	2
23	7	15	12	3
24	8	15	13	1
25	8	15	13	2
26	8	15	13	3
27	8	15	13	4
28	9	95	8	1
29	9	95	8	2
30	9	95	8	3
31	10	95	8	1
32	10	95	8	2
33	10	95	8	3
34	10	95	8	4
35	11	95	6	1
36	11	95	6	2
37	11	95	6	3
38	12	95	8	1
39	12	95	8	2
40	12	95	8	3
41	13	95	8	1
42	13	95	8	2
43	13	95	8	3
44	13	95	8	4
45	14	70	10	1
46	14	70	10	2
47	14	70	10	3
48	15	70	9	1
49	15	70	9	2
50	15	70	9	3
51	16	70	10	1
52	16	70	10	2
53	16	70	10	3
54	17	70	9	1
55	17	70	9	2
56	17	70	9	3
57	17	70	9	4
58	18	40	12	1
59	18	40	12	2
60	18	40	12	3
61	18	40	12	4
62	19	40	12	1
63	19	40	12	2
64	19	40	12	3
65	20	40	12	1
66	20	40	12	2
67	20	40	12	3
68	20	40	12	4
69	21	85	7	1
70	21	85	7	2
71	21	85	7	3
72	22	85	7	1
73	22	85	7	2
74	22	85	7	3
75	23	85	8	1
76	23	85	8	2
77	23	85	8	3
78	23	85	8	4
79	24	85	6	1
80	24	85	6	2
81	24	85	6	3
82	25	100	10	1
83	25	100	10	2
84	25	100	10	3
85	26	100	12	1
86	26	100	12	2
87	26	100	12	3
88	27	100	10	1
89	27	100	10	2
90	27	100	10	3
91	27	100	10	4
92	28	100	8	1
93	28	100	8	2
94	28	100	8	3
95	28	100	8	4
96	29	50	11	1
97	29	50	11	2
98	29	50	11	3
99	30	50	12	1
100	30	50	12	2
101	30	50	12	3
102	31	50	10	1
103	31	50	10	2
104	31	50	10	3
105	31	50	10	4
106	32	50	14	1
107	32	50	14	2
108	32	50	14	3
109	32	50	14	4
110	33	120	9	1
111	33	120	9	2
112	33	120	9	3
113	33	120	9	4
114	34	120	8	1
115	34	120	8	2
116	34	120	8	3
117	35	120	7	1
118	35	120	7	2
119	35	120	7	3
120	36	120	7	1
121	36	120	7	2
122	36	120	7	3
123	36	120	7	4
124	37	80	9	1
125	37	80	9	2
126	37	80	9	3
127	38	80	8	1
128	38	80	8	2
129	38	80	8	3
130	39	80	9	1
131	39	80	9	2
132	39	80	9	3
133	39	80	9	4
134	40	80	12	1
135	40	80	12	2
136	40	80	12	3
137	41	15	11	1
138	41	15	11	2
139	41	15	11	3
140	41	15	11	4
141	42	15	14	1
142	42	15	14	2
143	42	15	14	3
144	42	15	14	4
145	43	15	10	1
146	43	15	10	2
147	43	15	10	3
148	43	15	10	4
149	44	15	14	1
150	44	15	14	2
151	44	15	14	3
152	45	95	8	1
153	45	95	8	2
154	45	95	8	3
155	45	95	8	4
156	46	95	7	1
157	46	95	7	2
158	46	95	7	3
159	46	95	7	4
160	47	95	6	1
161	47	95	6	2
162	47	95	6	3
163	47	95	6	4
164	48	95	9	1
165	48	95	9	2
166	48	95	9	3
167	48	95	9	4
168	49	95	8	1
169	49	95	8	2
170	49	95	8	3
171	50	70	8	1
172	50	70	8	2
173	50	70	8	3
174	50	70	8	4
175	51	70	10	1
176	51	70	10	2
177	51	70	10	3
178	52	70	8	1
179	52	70	8	2
180	52	70	8	3
181	53	70	12	1
182	53	70	12	2
183	53	70	12	3
184	53	70	12	4
185	54	40	10	1
186	54	40	10	2
187	54	40	10	3
188	54	40	10	4
189	55	40	14	1
190	55	40	14	2
191	55	40	14	3
192	56	40	14	1
193	56	40	14	2
194	56	40	14	3
195	56	40	14	4
196	57	85	8	1
197	57	85	8	2
198	57	85	8	3
199	57	85	8	4
200	58	85	8	1
201	58	85	8	2
202	58	85	8	3
203	59	85	6	1
204	59	85	6	2
205	59	85	6	3
206	60	85	9	1
207	60	85	9	2
208	60	85	9	3
209	60	85	9	4
210	61	100	12	1
211	61	100	12	2
212	61	100	12	3
213	62	100	9	1
214	62	100	9	2
215	62	100	9	3
216	62	100	9	4
217	63	100	10	1
218	63	100	10	2
219	63	100	10	3
220	63	100	10	4
221	64	100	9	1
222	64	100	9	2
223	64	100	9	3
224	64	100	9	4
225	65	50	10	1
226	65	50	10	2
227	65	50	10	3
228	66	50	12	1
229	66	50	12	2
230	66	50	12	3
231	66	50	12	4
232	67	50	13	1
233	67	50	13	2
234	67	50	13	3
235	68	50	11	1
236	68	50	11	2
237	68	50	11	3
238	69	120	8	1
239	69	120	8	2
240	69	120	8	3
241	69	120	8	4
242	70	120	7	1
243	70	120	7	2
244	70	120	7	3
245	70	120	7	4
246	71	120	9	1
247	71	120	9	2
248	71	120	9	3
249	71	120	9	4
250	72	120	9	1
251	72	120	9	2
252	72	120	9	3
253	72	120	9	4
254	73	80	8	1
255	73	80	8	2
256	73	80	8	3
257	73	80	8	4
258	74	80	10	1
259	74	80	10	2
260	74	80	10	3
261	74	80	10	4
262	75	80	10	1
263	75	80	10	2
264	75	80	10	3
265	76	80	11	1
266	76	80	11	2
267	76	80	11	3
268	76	80	11	4
269	77	15	12	1
270	77	15	12	2
271	77	15	12	3
272	78	15	14	1
273	78	15	14	2
274	78	15	14	3
275	78	15	14	4
276	79	15	13	1
277	79	15	13	2
278	79	15	13	3
279	80	15	14	1
280	80	15	14	2
281	80	15	14	3
282	81	95	7	1
283	81	95	7	2
284	81	95	7	3
285	81	95	7	4
286	82	95	9	1
287	82	95	9	2
288	82	95	9	3
289	82	95	9	4
290	83	95	9	1
291	83	95	9	2
292	83	95	9	3
293	84	95	8	1
294	84	95	8	2
295	84	95	8	3
296	84	95	8	4
297	85	95	8	1
298	85	95	8	2
299	85	95	8	3
300	86	70	12	1
301	86	70	12	2
302	86	70	12	3
303	87	70	12	1
304	87	70	12	2
305	87	70	12	3
306	87	70	12	4
307	88	70	8	1
308	88	70	8	2
309	88	70	8	3
310	88	70	8	4
311	89	70	11	1
312	89	70	11	2
313	89	70	11	3
314	89	70	11	4
315	90	40	11	1
316	90	40	11	2
317	90	40	11	3
318	90	40	11	4
319	91	40	12	1
320	91	40	12	2
321	91	40	12	3
322	92	40	10	1
323	92	40	10	2
324	92	40	10	3
325	93	85	6	1
326	93	85	6	2
327	93	85	6	3
328	93	85	6	4
329	94	85	9	1
330	94	85	9	2
331	94	85	9	3
332	94	85	9	4
333	95	85	9	1
334	95	85	9	2
335	95	85	9	3
336	96	85	8	1
337	96	85	8	2
338	96	85	8	3
339	97	10	11	1
340	97	10	11	2
341	97	10	11	3
342	97	10	11	4
343	98	10	13	1
344	98	10	13	2
345	98	10	13	3
346	98	10	13	4
347	99	10	10	1
348	99	10	10	2
349	99	10	10	3
350	100	10	13	1
351	100	10	13	2
352	100	10	13	3
353	100	10	13	4
354	101	10	12	1
355	101	10	12	2
356	101	10	12	3
357	102	10	13	1
358	102	10	13	2
359	102	10	13	3
360	103	65	12	1
361	103	65	12	2
362	103	65	12	3
363	103	65	12	4
364	104	65	9	1
365	104	65	9	2
366	104	65	9	3
367	105	65	9	1
368	105	65	9	2
369	105	65	9	3
370	105	65	9	4
371	106	65	9	1
372	106	65	9	2
373	106	65	9	3
374	106	65	9	4
375	107	65	9	1
376	107	65	9	2
377	107	65	9	3
378	108	10	14	1
379	108	10	14	2
380	108	10	14	3
381	108	10	14	4
382	109	10	11	1
383	109	10	11	2
384	109	10	11	3
385	109	10	11	4
386	110	10	11	1
387	110	10	11	2
388	110	10	11	3
389	110	10	11	4
390	111	10	12	1
391	111	10	12	2
392	111	10	12	3
393	111	10	12	4
394	112	10	14	1
395	112	10	14	2
396	112	10	14	3
397	112	10	14	4
398	113	10	11	1
399	113	10	11	2
400	113	10	11	3
401	113	10	11	4
402	114	65	10	1
403	114	65	10	2
404	114	65	10	3
405	114	65	10	4
406	115	65	10	1
407	115	65	10	2
408	115	65	10	3
409	115	65	10	4
410	116	65	8	1
411	116	65	8	2
412	116	65	8	3
413	117	65	12	1
414	117	65	12	2
415	117	65	12	3
416	117	65	12	4
417	118	65	9	1
418	118	65	9	2
419	118	65	9	3
420	118	65	9	4
421	119	10	10	1
422	119	10	10	2
423	119	10	10	3
424	120	10	11	1
425	120	10	11	2
426	120	10	11	3
427	120	10	11	4
428	121	10	11	1
429	121	10	11	2
430	121	10	11	3
431	122	10	10	1
432	122	10	10	2
433	122	10	10	3
434	122	10	10	4
435	123	10	11	1
436	123	10	11	2
437	123	10	11	3
438	123	10	11	4
439	124	10	13	1
440	124	10	13	2
441	124	10	13	3
442	124	10	13	4
443	125	65	11	1
444	125	65	11	2
445	125	65	11	3
446	125	65	11	4
447	126	65	11	1
448	126	65	11	2
449	126	65	11	3
450	127	65	9	1
451	127	65	9	2
452	127	65	9	3
453	128	65	12	1
454	128	65	12	2
455	128	65	12	3
456	129	65	9	1
457	129	65	9	2
458	129	65	9	3
459	129	65	9	4
460	130	10	14	1
461	130	10	14	2
462	130	10	14	3
463	130	10	14	4
464	131	10	10	1
465	131	10	10	2
466	131	10	10	3
467	132	10	14	1
468	132	10	14	2
469	132	10	14	3
470	133	10	11	1
471	133	10	11	2
472	133	10	11	3
473	133	10	11	4
474	134	10	11	1
475	134	10	11	2
476	134	10	11	3
477	134	10	11	4
478	135	10	12	1
479	135	10	12	2
480	135	10	12	3
481	135	10	12	4
482	136	65	10	1
483	136	65	10	2
484	136	65	10	3
485	136	65	10	4
486	137	65	9	1
487	137	65	9	2
488	137	65	9	3
489	138	65	8	1
490	138	65	8	2
491	138	65	8	3
492	139	65	8	1
493	139	65	8	2
494	139	65	8	3
495	139	65	8	4
496	140	65	8	1
497	140	65	8	2
498	140	65	8	3
499	141	10	11	1
500	141	10	11	2
501	141	10	11	3
502	142	10	14	1
503	142	10	14	2
504	142	10	14	3
505	143	10	14	1
506	143	10	14	2
507	143	10	14	3
508	144	10	14	1
509	144	10	14	2
510	144	10	14	3
511	145	10	12	1
512	145	10	12	2
513	145	10	12	3
514	146	10	13	1
515	146	10	13	2
516	146	10	13	3
517	147	65	11	1
518	147	65	11	2
519	147	65	11	3
520	147	65	11	4
521	148	65	8	1
522	148	65	8	2
523	148	65	8	3
524	149	65	9	1
525	149	65	9	2
526	149	65	9	3
527	150	65	9	1
528	150	65	9	2
529	150	65	9	3
530	151	65	11	1
531	151	65	11	2
532	151	65	11	3
533	151	65	11	4
534	152	10	13	1
535	152	10	13	2
536	152	10	13	3
537	153	10	12	1
538	153	10	12	2
539	153	10	12	3
540	154	10	14	1
541	154	10	14	2
542	154	10	14	3
543	155	10	10	1
544	155	10	10	2
545	155	10	10	3
546	156	10	14	1
547	156	10	14	2
548	156	10	14	3
549	156	10	14	4
550	157	10	11	1
551	157	10	11	2
552	157	10	11	3
553	158	65	11	1
554	158	65	11	2
555	158	65	11	3
556	158	65	11	4
557	159	65	9	1
558	159	65	9	2
559	159	65	9	3
560	160	65	12	1
561	160	65	12	2
562	160	65	12	3
563	160	65	12	4
564	161	65	12	1
565	161	65	12	2
566	161	65	12	3
567	161	65	12	4
568	162	65	8	1
569	162	65	8	2
570	162	65	8	3
572	165	50	10	1
573	165	50	10	2
574	166	25	12	1
575	167	40	8	1
576	167	40	8	2
577	168	12	12	1
578	169	52.5	10	1
579	169	52.5	10	2
580	170	26.25	12	1
581	171	42.5	8	1
582	171	42.5	8	2
583	172	12.75	12	1
584	173	55	10	1
585	173	55	10	2
586	174	27.5	12	1
587	175	45	8	1
588	175	45	8	2
589	176	13.5	12	1
590	177	57.5	10	1
591	177	57.5	10	2
592	178	28.75	12	1
593	179	47.5	8	1
594	179	47.5	8	2
595	180	14.25	12	1
596	181	60	10	1
597	181	60	10	2
598	182	30	12	1
599	183	50	8	1
600	183	50	8	2
601	184	15	12	1
602	185	62.5	10	1
603	185	62.5	10	2
604	186	31.25	12	1
605	187	52.5	8	1
606	187	52.5	8	2
607	188	15.75	12	1
608	189	65	10	1
609	189	65	10	2
610	190	32.5	12	1
611	191	55	8	1
612	191	55	8	2
613	192	16.5	12	1
614	193	67.5	10	1
615	193	67.5	10	2
616	194	33.75	12	1
617	195	57.5	8	1
618	195	57.5	8	2
619	196	17.25	12	1
620	197	70	10	1
621	197	70	10	2
622	198	35	12	1
623	199	60	8	1
624	199	60	8	2
625	200	18	12	1
626	201	72.5	10	1
627	201	72.5	10	2
628	202	36.25	12	1
629	203	62.5	8	1
630	203	62.5	8	2
631	204	18.75	12	1
632	205	75	10	1
633	205	75	10	2
634	206	37.5	12	1
635	207	65	8	1
636	207	65	8	2
637	208	19.5	12	1
638	209	77.5	10	1
639	209	77.5	10	2
640	210	38.75	12	1
641	211	67.5	8	1
642	211	67.5	8	2
643	212	20.25	12	1
644	214	60	10	1
645	214	65	8	2
646	215	20	12	1
647	215	20	12	2
648	216	0	10	1
649	216	0	8	2
650	217	25	12	1
651	217	25	12	2
652	218	80	5	1
653	218	80	5	2
654	219	30	12	1
655	219	30	12	2
656	220	58	8	1
657	220	58	5	2
658	220	58	6	3
659	220	58	5	4
660	221	68	5	1
661	221	68	3	2
662	221	68	3	3
663	221	68	3	4
664	222	68	6	1
665	222	68	5	2
666	222	68	5	3
667	222	68	4	4
668	223	70	5	1
669	223	70	5	2
670	223	70	5	3
671	223	70	5	4
672	224	72.5	5	1
673	224	72.5	5	2
674	224	72.5	5	3
675	224	72.5	7	4
676	225	75	6	1
677	225	75	6	2
678	225	75	6	3
679	225	75	7	4
680	226	80	5	1
681	226	80	5	2
682	226	80	5	3
683	226	80	6	4
684	227	100	1	1
685	227	85	7	2
686	227	85	6	3
687	227	85	6	4
688	228	90	4	1
689	228	90	4	2
690	228	90	3	3
691	228	85	7	4
692	229	80	8	1
693	229	80	8	2
694	229	80	8	3
695	229	80	8	4
696	230	35	8	1
697	230	35	8	2
698	230	35	8	3
699	230	35	8	4
700	231	25	10	1
701	231	25	10	2
702	231	25	9	3
703	231	25	9	4
704	232	80	10	1
705	232	80	9	2
706	232	80	9	3
707	232	80	9	4
708	233	12	12	1
709	233	12	12	2
710	233	12	12	3
711	233	12	12	4
712	234	90	4	1
713	234	90	4	2
714	234	90	3	3
715	234	90	7	4
716	235	59	12	1
717	235	59	11	2
718	235	59	10	3
719	236	32	12	1
720	236	32	12	2
721	236	32	12	3
722	237	86.5	10	1
723	237	86.5	10	2
724	237	86.5	10	3
725	238	32	12	1
726	238	32	12	2
727	238	32	9	3
728	239	60	8	1
729	239	60	8	2
730	239	60	8	3
731	239	60	8	4
732	240	25	10	1
733	240	25	9	2
734	240	25	9	3
735	241	35	12	1
736	241	35	12	2
737	241	35	12	3
738	242	12	12	1
739	242	12	12	2
740	242	12	12	3
741	243	52.5	7	1
742	243	52.5	7	2
743	243	52.5	6	3
744	243	52.5	7	4
745	244	22	9	1
746	244	22	8	2
747	244	22	8	3
748	245	27	10	1
749	245	27	9	2
750	245	27	9	3
751	246	28	12	1
752	246	28	12	2
753	246	28	12	3
754	246	28	12	4
755	247	86	11	1
756	247	86	8	2
757	248	55	8	1
758	248	55	8	2
759	248	55	8	3
760	248	55	8	4
761	249	22	10	1
762	249	22	10	2
763	249	22	10	3
764	250	66	10	1
765	250	66	10	2
766	250	66	10	3
767	251	23	12	1
768	251	23	12	2
769	251	23	12	3
770	251	23	12	4
771	252	58	8	1
772	252	58	8	2
773	252	58	8	3
774	253	84	7	1
775	253	84	5	2
776	253	84	4	3
777	254	52	12	1
778	254	52	12	2
779	254	52	13	3
780	255	77	12	1
781	255	77	12	2
782	255	77	12	3
783	256	27	12	1
784	256	27	12	2
785	256	27	12	3
786	257	45	12	1
787	257	45	12	2
788	257	45	11	3
789	258	12	12	1
790	258	12	10	2
791	259	60	8	1
792	259	60	8	2
793	259	60	8	3
794	259	60	6	4
795	260	24	8	1
796	260	24	7	2
797	260	24	7	3
798	261	66	11	1
799	261	66	10	2
800	261	66	10	3
801	262	23	13	1
802	262	23	13	2
803	262	23	13	3
804	262	23	13	4
805	263	86	12	1
806	263	86	12	2
807	263	86	12	3
808	264	59	12	1
809	264	59	11	2
810	264	59	10	3
811	265	32	12	1
812	265	32	12	2
813	265	32	12	3
814	266	86	10	1
815	266	86	10	2
816	266	86	10	3
817	267	32	12	1
818	267	32	12	2
819	267	32	9	3
820	268	52	12	1
821	268	52	11	2
822	268	52	9	3
823	269	85	5	1
824	269	85	5	2
825	269	85	6	3
826	270	24	8	1
827	270	24	8	2
828	270	24	7	3
829	271	66	12	1
830	271	66	10	2
831	271	66	8	3
832	272	36	12	1
833	272	36	12	2
834	272	36	12	3
835	272	36	12	4
836	273	95	9	1
837	273	95	9	2
838	273	95	10	3
839	274	84	7	1
840	274	84	5	2
841	274	84	4	3
842	275	52	11	1
843	275	52	11	2
844	275	52	10	3
845	276	77	10	1
846	276	77	10	2
847	276	77	11	3
848	277	12	10	1
849	277	12	8	2
850	277	12	8	3
851	278	45	12	1
852	278	45	10	2
853	278	45	10	3
854	279	45	12	1
855	279	50	6	2
856	279	50	6	3
857	279	50	6	4
858	280	22	6	1
859	280	22	7	2
860	280	22	7	3
861	281	27	10	1
862	281	27	8	2
863	281	27	7	3
864	282	14	12	1
865	282	14	12	2
866	282	14	12	3
867	282	14	12	4
868	283	68	14	1
869	283	77	12	2
870	283	77	12	3
871	284	83	8	1
872	284	83	7	2
873	284	83	6	3
874	285	67	10	1
875	285	67	9	2
876	285	67	9	3
877	286	32	12	1
878	286	32	12	2
879	286	32	12	3
880	287	45	11	1
881	287	45	11	2
882	287	45	11	3
883	288	90	5	1
884	288	90	5	2
885	288	90	5	3
886	288	90	6	4
887	289	120	5	1
888	289	120	4	2
889	289	120	4	3
890	289	120	4	4
891	290	80	5	1
892	290	80	5	2
893	290	80	5	3
894	290	80	4	4
895	291	90	5	1
896	291	90	5	2
897	291	90	5	3
898	291	90	6	4
899	292	25	10	1
900	292	25	9	2
901	292	25	9	3
902	293	25	12	1
903	293	25	12	2
904	293	25	12	3
905	293	25	12	4
906	294	80	8	1
907	294	80	8	2
908	294	80	8	3
909	294	80	8	4
\.


--
-- TOC entry 5125 (class 0 OID 16446)
-- Dependencies: 229
-- Data for Name: workouts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.workouts (id, user_id, date, duration) FROM stdin;
1	1	2025-12-01 08:00:00	\N
2	2	2025-12-01 09:00:00	\N
3	3	2025-12-01 10:00:00	\N
4	1	2025-12-03 08:00:00	\N
5	2	2025-12-03 09:00:00	\N
6	3	2025-12-03 10:00:00	\N
7	1	2025-12-05 08:00:00	\N
8	2	2025-12-05 09:00:00	\N
9	3	2025-12-05 10:00:00	\N
10	1	2025-12-08 08:00:00	\N
11	2	2025-12-08 09:00:00	\N
12	3	2025-12-08 10:00:00	\N
13	1	2025-12-10 08:00:00	\N
14	2	2025-12-10 09:00:00	\N
15	3	2025-12-10 10:00:00	\N
16	1	2025-12-12 08:00:00	\N
17	2	2025-12-12 09:00:00	\N
18	3	2025-12-12 10:00:00	\N
19	1	2025-12-15 08:00:00	\N
20	2	2025-12-15 09:00:00	\N
21	3	2025-12-15 10:00:00	\N
22	1	2025-12-17 08:00:00	\N
23	2	2025-12-17 09:00:00	\N
24	3	2025-12-17 10:00:00	\N
25	4	2025-12-01 16:00:00	\N
26	5	2025-12-01 17:00:00	\N
27	4	2025-12-03 16:00:00	\N
28	5	2025-12-03 17:00:00	\N
29	4	2025-12-05 16:00:00	\N
30	5	2025-12-05 17:00:00	\N
31	4	2025-12-08 16:00:00	\N
32	5	2025-12-08 17:00:00	\N
33	4	2025-12-10 16:00:00	\N
34	5	2025-12-10 17:00:00	\N
35	4	2025-12-12 16:00:00	\N
36	5	2025-12-12 17:00:00	\N
39	7	2025-12-29 00:00:00	\N
40	7	2026-01-01 00:00:00	\N
41	7	2025-12-22 00:00:00	\N
42	7	2025-12-25 00:00:00	\N
43	7	2025-12-15 00:00:00	\N
44	7	2025-12-18 00:00:00	\N
45	7	2025-12-08 00:00:00	\N
46	7	2025-12-11 00:00:00	\N
47	7	2025-12-01 00:00:00	\N
48	7	2025-12-04 00:00:00	\N
49	7	2025-11-24 00:00:00	\N
50	7	2025-11-27 00:00:00	\N
51	7	2025-11-17 00:00:00	\N
52	7	2025-11-20 00:00:00	\N
53	7	2025-11-10 00:00:00	\N
54	7	2025-11-13 00:00:00	\N
55	7	2025-11-03 00:00:00	\N
56	7	2025-11-06 00:00:00	\N
57	7	2025-10-27 00:00:00	\N
58	7	2025-10-30 00:00:00	\N
59	7	2025-10-20 00:00:00	\N
60	7	2025-10-23 00:00:00	\N
61	7	2025-10-13 00:00:00	\N
62	7	2025-10-16 00:00:00	\N
64	1	2025-12-23 00:00:00	\N
65	1	2025-12-24 00:00:00	\N
66	1	2025-12-26 00:00:00	\N
67	1	2025-12-28 00:00:00	\N
77	7	2026-01-02 22:57:01.368517	01:21:40
78	7	2026-01-02 23:04:10.998172	00:00:52
82	16	2025-12-10 18:30:00	01:31:20
83	16	2025-12-17 17:00:00	01:35:05
84	16	2025-12-18 19:15:00	01:29:50
85	16	2025-12-24 16:45:00	01:30:15
86	16	2025-12-25 18:00:00	01:32:10
87	16	2025-12-30 17:30:00	01:28:45
88	16	2025-12-08 17:30:00	01:28:45
89	16	2025-12-07 17:30:00	01:28:45
68	15	2025-12-05 17:30:00	01:10:00
69	15	2025-12-08 18:00:00	00:55:00
70	15	2025-12-10 16:45:00	01:20:00
71	15	2025-12-13 10:30:00	01:05:00
72	15	2025-12-15 19:00:00	00:48:00
73	15	2025-12-17 18:15:00	01:15:00
74	15	2025-12-20 11:00:00	01:02:00
75	15	2025-12-22 17:00:00	00:58:00
76	15	2025-12-27 12:00:00	01:30:00
79	15	2025-12-30 18:30:00	01:12:00
80	15	2026-01-02 16:00:00	01:05:00
81	15	2026-01-04 15:00:00	00:50:00
90	15	2026-01-05 17:15:00	01:10:00
91	15	2026-01-05 18:38:45.595437	00:01:06
92	15	2026-01-10 14:44:43.987412	00:03:16
93	7	2026-01-12 13:48:58.204066	230:31:34
94	7	2026-01-12 18:29:18.678663	00:00:13
\.


--
-- TOC entry 5145 (class 0 OID 0)
-- Dependencies: 226
-- Name: body_measurements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.body_measurements_id_seq', 17, true);


--
-- TOC entry 5146 (class 0 OID 0)
-- Dependencies: 224
-- Name: exercises_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.exercises_id_seq', 103, true);


--
-- TOC entry 5147 (class 0 OID 0)
-- Dependencies: 222
-- Name: muscle_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.muscle_groups_id_seq', 9, true);


--
-- TOC entry 5148 (class 0 OID 0)
-- Dependencies: 220
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 18, true);


--
-- TOC entry 5149 (class 0 OID 0)
-- Dependencies: 230
-- Name: workout_exercises_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.workout_exercises_id_seq', 294, true);


--
-- TOC entry 5150 (class 0 OID 0)
-- Dependencies: 232
-- Name: workout_sets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.workout_sets_id_seq', 909, true);


--
-- TOC entry 5151 (class 0 OID 0)
-- Dependencies: 228
-- Name: workouts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.workouts_id_seq', 94, true);


--
-- TOC entry 4956 (class 2606 OID 16439)
-- Name: body_measurements body_measurements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.body_measurements
    ADD CONSTRAINT body_measurements_pkey PRIMARY KEY (id);


--
-- TOC entry 4954 (class 2606 OID 16424)
-- Name: exercises exercises_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exercises
    ADD CONSTRAINT exercises_pkey PRIMARY KEY (id);


--
-- TOC entry 4952 (class 2606 OID 16412)
-- Name: muscle_groups muscle_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.muscle_groups
    ADD CONSTRAINT muscle_groups_pkey PRIMARY KEY (id);


--
-- TOC entry 4950 (class 2606 OID 16403)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 4960 (class 2606 OID 16469)
-- Name: workout_exercises workout_exercises_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workout_exercises
    ADD CONSTRAINT workout_exercises_pkey PRIMARY KEY (id);


--
-- TOC entry 4962 (class 2606 OID 16490)
-- Name: workout_sets workout_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workout_sets
    ADD CONSTRAINT workout_sets_pkey PRIMARY KEY (id);


--
-- TOC entry 4958 (class 2606 OID 16454)
-- Name: workouts workouts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workouts
    ADD CONSTRAINT workouts_pkey PRIMARY KEY (id);


--
-- TOC entry 4964 (class 2606 OID 16440)
-- Name: body_measurements body_measurements_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.body_measurements
    ADD CONSTRAINT body_measurements_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 4963 (class 2606 OID 16425)
-- Name: exercises exercises_muscle_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exercises
    ADD CONSTRAINT exercises_muscle_group_id_fkey FOREIGN KEY (muscle_group_id) REFERENCES public.muscle_groups(id);


--
-- TOC entry 4966 (class 2606 OID 16475)
-- Name: workout_exercises workout_exercises_exercise_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workout_exercises
    ADD CONSTRAINT workout_exercises_exercise_id_fkey FOREIGN KEY (exercise_id) REFERENCES public.exercises(id);


--
-- TOC entry 4967 (class 2606 OID 16470)
-- Name: workout_exercises workout_exercises_workout_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workout_exercises
    ADD CONSTRAINT workout_exercises_workout_id_fkey FOREIGN KEY (workout_id) REFERENCES public.workouts(id);


--
-- TOC entry 4968 (class 2606 OID 16491)
-- Name: workout_sets workout_sets_workout_exercise_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workout_sets
    ADD CONSTRAINT workout_sets_workout_exercise_id_fkey FOREIGN KEY (workout_exercise_id) REFERENCES public.workout_exercises(id);


--
-- TOC entry 4965 (class 2606 OID 16455)
-- Name: workouts workouts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workouts
    ADD CONSTRAINT workouts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


-- Completed on 2026-01-13 18:55:39

--
-- PostgreSQL database dump complete
--

\unrestrict 2bfLs3J59zqLM9lrANlt2fbZL0BrtB1nmOOtz8XTLrDSLPZjIbtqsTieemJcxn0

