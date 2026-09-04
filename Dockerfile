FROM ttyd/ttyd:1.7

EXPOSE 8080
CMD ["ttyd", "--writable", "--port", "8080", "bash"]
