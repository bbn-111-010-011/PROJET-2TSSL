# Supabase - table historique des achats en français

Dans Supabase, ouvre **SQL Editor** puis exécute ce script.

```sql
create extension if not exists pgcrypto;

create table if not exists public.historique_achats (
  id_achat uuid primary key default gen_random_uuid(),
  date_achat timestamptz not null default now(),
  id_utilisateur integer,
  email_utilisateur text,
  articles jsonb not null,
  statut_achat text not null default 'valide',
  montant numeric not null,
  nom_produits text,
  categories_produits text
);

alter table public.historique_achats
add column if not exists nom_produits text;

alter table public.historique_achats
add column if not exists categories_produits text;

alter table public.historique_achats enable row level security;

drop policy if exists "historique_achats_insert_public" on public.historique_achats;
drop policy if exists "historique_achats_select_public" on public.historique_achats;

create policy "historique_achats_insert_public"
on public.historique_achats
for insert
with check (true);

create policy "historique_achats_select_public"
on public.historique_achats
for select
using (true);

notify pgrst, 'reload schema';
```

## Colonnes utilisées par Flutter

| Colonne | Type | Rôle |
|---|---|---|
| `id_achat` | uuid | Identifiant de l'achat |
| `date_achat` | timestamptz | Date automatique de validation |
| `id_utilisateur` | integer | Identifiant de l'utilisateur connecté |
| `email_utilisateur` | text | Email de l'utilisateur connecté |
| `articles` | jsonb | Détail complet des produits achetés |
| `statut_achat` | text | Statut de la commande |
| `montant` | numeric | Total de la commande |
| `nom_produits` | text | Noms des produits, visibles directement dans la table |
| `categories_produits` | text | Catégories des produits, visibles directement dans la table |

## Exemple de contenu de `articles`

```json
[
  {
    "id_produit": 10,
    "nom_produit": "Classic Black Baseball Cap",
    "categorie": "Clothes",
    "prix": 58.0,
    "quantite": 1,
    "image": "https://...",
    "total_ligne": 58.0
  }
]
```
