.PHONY: build-layer plan apply destroy clean

build-layer:
	./scripts/build_layer.sh

plan:
	cd terraform && terraform init && terraform plan

apply:
	cd terraform && terraform init && terraform apply

destroy:
	cd terraform && terraform destroy

clean:
	rm -rf .build
	rm -f artifacts/pillow_layer.zip artifacts/watermark_lambda.zip
