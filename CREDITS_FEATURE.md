# Gestion des Crédits - Documentation

## Vue d'ensemble

Cette fonctionnalité permet de gérer les paiements des bons de pesée qui ont un crédit restant. Elle comprend :

1. **Une section dans le dashboard** qui affiche le total des crédits
2. **Une page de liste** des bons avec crédit restant
3. **Un formulaire de paiement** pour enregistrer les paiements

## Architecture

### Modèles créés

#### 1. `lib/models/entities/payment.dart`
Entité représentant un paiement :
- `id`: Identifiant du paiement
- `weighingSlipId`: ID du bon de pesée
- `paymentType`: Type de paiement (cash, check, guarantee_check)
- `amountPaid`: Montant payé
- `paymentDate`: Date du paiement
- Champs pour les chèques (numéro, banque, date, statut)
- `notes`: Notes optionnelles

#### 2. `lib/models/request/create_payment_request.dart`
Request pour créer un paiement avec tous les champs nécessaires.

#### 3. `lib/models/response/payment_response.dart`
Response contenant le résultat de la création d'un paiement.

### Services

#### `lib/services/payment_service.dart`
Service gérant les opérations liées aux paiements :
- `createPayment()`: Enregistre un nouveau paiement (POST /payments)
- `getSlipsWithCredit()`: Récupère les bons non entièrement payés
- `getPaymentsForSlip()`: Récupère les paiements d'un bon spécifique

**Endpoint principal** : `POST /payments`

### ViewModels

#### `lib/viewmodels/credit_payment_viewmodel.dart`
ViewModel gérant l'état de la page des crédits :
- Liste des bons avec crédit
- Pagination
- Création de paiements
- Calcul du total des crédits

### Vues

#### 1. `lib/views/credits/credits_content.dart`
Page principale affichant :
- Carte récapitulative du crédit total
- Barre de recherche
- Tableau des bons avec crédit contenant :
  - N° de bon
  - Client
  - Date
  - Montant total
  - Montant payé
  - Crédit restant
  - Bouton "Payer"
- Pagination

#### 2. `lib/views/credits/payment_form_dialog.dart`
Formulaire modal pour enregistrer un paiement :
- Type de paiement (Espèces/Chèque/Chèque de garantie)
- Montant à payer
- Date de paiement
- Champs spécifiques aux chèques :
  - Numéro de chèque
  - Banque
  - Date du chèque
  - Statut (En attente/Encaissé/Rejeté)
- Notes

**Validations** :
- Le montant ne peut pas dépasser le crédit restant
- Les champs chèque sont obligatoires si le type est chèque
- Gestion des erreurs de l'API avec messages personnalisés

#### 3. `lib/views/home/dashboard_content.dart` (modifié)
Ajout d'une carte "Crédits" cliquable qui redirige vers `/credits`.

### Routes

Nouvelle route ajoutée dans `lib/routes/app_router.dart` :
- `/credits` : Page de gestion des crédits

### Injection de dépendances

Configuration dans `lib/di/injection_container.dart` :
- `PaymentService` : Service singleton
- `CreditPaymentViewModel` : Factory pour chaque instance

## Utilisation

### Navigation vers la page des crédits

Depuis le dashboard, cliquer sur la carte "Crédits".

### Enregistrer un paiement

1. Dans la liste des bons avec crédit, cliquer sur le bouton "Payer"
2. Remplir le formulaire :
   - Sélectionner le type de paiement
   - Entrer le montant (par défaut = crédit restant)
   - Sélectionner la date
   - Si chèque : remplir les informations supplémentaires
   - Ajouter des notes (optionnel)
3. Cliquer sur "Enregistrer"

### Gestion des erreurs

L'application gère plusieurs types d'erreurs de l'API :
- `WEIGHING_SLIP_NOT_FOUND` : Bon introuvable
- `FORBIDDEN_NOT_TODAY` : Les employés ne peuvent payer que les bons d'aujourd'hui
- `CHECK_NOT_ALLOWED` : Le client ne peut pas payer par chèque
- `PAYMENT_EXCEEDS_REMAINING` : Le montant dépasse le crédit restant

## Endpoint Backend

### POST /payments

**Body** :
```json
{
  "weighing_slip_id": 123,
  "payment_type": "cash", // ou "check" ou "guarantee_check"
  "amount_paid": 1500.50,
  "payment_date": "2026-01-03",
  "check_number": "123456", // optionnel (obligatoire si chèque)
  "check_date": "2026-01-03", // optionnel (obligatoire si chèque)
  "check_bank": "BNA", // optionnel (obligatoire si chèque)
  "check_status": "pending", // optionnel: pending, cleared, bounced
  "notes": "Paiement partiel" // optionnel
}
```

**Response en cas de succès** :
```json
{
  "success": true,
  "data": {
    "id": 456,
    "weighing_slip_id": 123,
    "payment_type": "cash",
    "amount_paid": 1500.50,
    "payment_date": "2026-01-03",
    "created_by": 1,
    "created_at": "2026-01-03T10:30:00.000Z"
  }
}
```

**Response en cas d'erreur** :
```json
{
  "success": false,
  "error": "PAYMENT_EXCEEDS_REMAINING",
  "details": {
    "weighing_slip_id": 123,
    "remaining_credit": 1000.00,
    "requested_amount": 1500.50
  }
}
```

## Dépendances

Aucune nouvelle dépendance n'est nécessaire. Le projet utilise déjà :
- `provider` pour la gestion d'état
- `get_it` pour l'injection de dépendances
- `go_router` pour la navigation
- `intl` pour le formatage des nombres et dates
- `dio` pour les requêtes HTTP

## Tests recommandés

1. Tester la navigation vers la page des crédits
2. Vérifier l'affichage de la liste des bons avec crédit
3. Tester le paiement en espèces
4. Tester le paiement par chèque avec toutes les validations
5. Vérifier les messages d'erreur personnalisés
6. Tester la pagination
7. Vérifier le rafraîchissement de la liste après paiement
8. Tester avec un employé (restrictions sur les dates)
