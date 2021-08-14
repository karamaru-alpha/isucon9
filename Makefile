export GO111MODULE=on
DB_HOST:=127.0.0.1
DB_PORT:=3306
DB_USER:=isucari
DB_PASS:=isucari
DB_NAME:=isucari

NGX_LOG:=/var/log/nginx/access.log
MYSQL_LOG:=/tmp/slow-query.log


.PHONY: setup
setup:
	sudo apt install -y percona-toolkit git unzip
	git init
	git config --global user.name karamaru-alpha
	git config --global user.email mrnk3078@gmail.com
	git config credential.helper store
	wget https://github.com/matsuu/kataribe/releases/download/v0.4.1/kataribe-v0.4.1_linux_amd64.zip -O kataribe.zip
	unzip -o kataribe.zip
	sudo mv kataribe /usr/local/bin/
	sudo chmod +x /usr/local/bin/kataribe
	sudo rm kataribe.zip
	kataribe -generate


.PHONY: restart
restart:
	sudo systemctl restart nginx
	sudo systemctl restart isucari.golang.service

.PHONY: before-bench
before-bench:
	git pull
	$(eval when := $(shell date "+%s"))
	mkdir -p ~/logs/$(when)
	@if [ -f $(NGX_LOG) ]; then \
			sudo mv -f $(NGX_LOG) ~/logs/$(when)/ ; \
	fi
	@if [ -f $(MYSQL_LOG) ]; then \
			sudo mv -f $(MYSQL_LOG) ~/logs/$(when)/ ; \
	fi
#	sudo cp nginx.conf /etc/nginx/nginx.conf
#	sudo cp my.cnf /etc/mysql/my.cnf
	sudo systemctl restart nginx
	sudo systemctl restart mysql


.PHONY: kataru
kataru:
	sudo cat $(NGX_LOG) | kataribe -f ./kataribe.toml

.PHONY: sql
sql:
	mysql -h$(DB_HOST) -P$(DB_PORT) -u$(DB_USER) -p$(DB_PASS) $(DB_NAME)
