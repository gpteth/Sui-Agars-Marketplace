# Sui Agars Marketplace

Marketplace for trading agars using the Kiosk framework

## Publish

```bash
sui client publish --gas-budget 100000000 .
```

## Usage

```bash
# mint a agar
sui client call --function mint_agar --module agar --package $PACKAGE_ID --args "作者" "标题" "分类" "故事内容" --gas-budget 10000000

# create a marketplace
sui client call --function create_agar_marketplace --module agarsmarket --package $PACKAGE_ID --gas-budget 10000000

# place a agar
sui client call --function place_agar --module agarsmarket --package $PACKAGE_ID --args $KIOSK_ID $KIOSKOWNERCAP_ID $AGAR_ID --type-args $TYPE_ARGS --gas-budget 10000000

# list a agar
sui client call --function list_agar --module agarsmarket --package $PACKAGE_ID --args $KIOSK_ID $KIOSKOWNERCAP_ID $AGAR_ID $PRICE --type-args $TYPE_ARGS --gas-budget 10000000

# buy a agar
sui client call --function purchase_agar --module agarsmarket --package $PACKAGE_ID --args $KIOSK_ID $AGAR_ID --type-args $TYPE_ARGS --gas-budget 10000000

# add a rule for transferpolicy
sui client call --function add_agar_rule --module agarsrules --package $KIOSK_PACKAGE_ID --args $KIOSKTRANSFERPOLICY_ID $KIOSKTRANSFERPOLICYCAP_ID $AMOUNT_BP --type-args $TYPE_ARGS --gas-budget 10000000

```# Sui-Agars-Marketplace
