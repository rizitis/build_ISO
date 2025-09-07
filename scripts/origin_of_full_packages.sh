# We want to make that the "full" set includes only packages directly in /slint,
# not in one of its sub directories
CWD=$(pwd)
(cd ../../../slint
while read -r i; do
	find -name "${i}*txz"|grep "/${i}-[^-]*-[^-]*-[^-]*$"|grep -e /extra/ -e /ISO/ -e /dict/ -e /locales/ -e /voices/ -e /lxqt/ -e /testing/
done < $CWD/full
)
