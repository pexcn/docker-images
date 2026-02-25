# TinyFECVPN

## FEC Params

```sh
#
# generic
#
# 1% loss
-f1:2,2:2,8:3,20:4 --timeout 8
# 10% loss
-f1:3,2:4,8:6,20:10 --timeout 8
# 15% loss
-f1:3,2:4,4:5,8:6,12:9,20:12 --timeout 8

#
# game
#
# 1% loss
-f2:2 --timeout 1
# 10% loss
-f2:4 --timeout 1
```

## About `mode`

For advanced users, `--mode 1` can be used, but the MTU needs to be adjusted. I still need to run more tests on this option.
